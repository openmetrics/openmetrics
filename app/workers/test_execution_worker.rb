require 'selenium-webdriver'
require 'webtest_automagick'
require 'open3'

class TestExecutionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  include WebtestAutomagick

  TMPDIR="#{Rails.root}/tmp/test_executions" # working dir

  def perform(test_execution_id, test_plan_id)
    tp = TestPlan.find(test_plan_id)
    te = TestExecution.find(test_execution_id)
    te_result = te.test_execution_result

    # try preparation and execution of testplan
    te.update_attributes(started_at: Time.now)
    begin
      te_items = prepare(te, tp)
      te.update_attributes(status: EXECUTION_STATUS.key('prepared'))
      te_items.each do |tei|
        execute(tei[0], tei[1], tei[2])
      end
      te.update_attributes(finished_at: Time.now)
      # check test execution items for exitstatus indicating a fail
      # use the 'newest' TestExecutionItem exitstatus to mark for overall result:
      # FIXME when sidekiq is killed, failure detection of is not reliable. output may contain 'returned status: false (exitstatus )' (which indicates error) while exit status is not set. nevertheless exitstatus remains successful
      failed = te.test_execution_items.where(['exitstatus > ?', 0]).order('id')
      te_result.update_attributes(exitstatus: failed.last.exitstatus) if failed.any?
      # mark result success if status not yet decided
      te_result.update_attributes(exitstatus: 0) if te_result.exitstatus.nil?
    rescue Exception => e
      # job preparation or execution failed,
      logger.warn "preparation or execution of TestExecution##{te.id} thrown exception #{e.message}"
      logger.debug e.backtrace.inspect
    ensure
      # persist execution finished
      te.update_attributes(finished_at: Time.now)
    end
    # test execution finished
    te.update_attributes(status: EXECUTION_STATUS.key('finished'))
    # FIXME remove (delete) create executable
  end

  # reads test plans test_items and generates executables of it (TestExecutionItem) depending on item format/markup
  # returns pairs of arrays (test_execution_item_id, filename, interpreter)
  def prepare(te, tp)
    ret = []
    items = tp.test_items
    items.each_with_index { |item, n|
      # executable header (shebang) and extension
      header = ''
      interpreter = ''
      case item.format
        when 'selenese'
          header = "#!/usr/bin/env ruby\n"
          interpreter = 'ruby'
        when 'bash'
          header = "#!/bin/bash\n"
          interpreter = 'bash'
      end

      # create executable file and change pwd (ugly way w/ ruby core utils)
      Dir.mkdir(TMPDIR) unless Dir.exist?(TMPDIR)
      Dir.chdir(TMPDIR)
      Dir.mkdir(te.id.to_s) unless Dir.exist?(te.id.to_s)
      Dir.chdir(te.id.to_s)
      dir = Dir.pwd
      filename = dir+"/#{n+1}_#{item.id}"

      # prepare (and convert) markup and format
      conversion_format = item.format
      executable_markup = if item.type == 'TestCase' && item.format == 'selenese'
                            selenese_to_webdriver(item.markup, tp.base_url) # translates to ruby, pass
                          else
                            item.markup # use item.markup by default
                          end

      # overwrite format for converted if needed
      if item.type == 'TestCase' && item.format == 'selenese'
        conversion_format = 'ruby' # format should be ruby
      end

      # append newline to make humans interacting via terminals happy
      executable_markup+="\n" unless executable_markup.ends_with? "\n"

      # persist as TestExecutionItem
      te_item = TestExecutionItem.create!(
          markup: header+executable_markup,
          format: conversion_format,
          executable: filename,
          test_item_id: item.id,
          test_execution_id: te.id
      )


      # write executable file to filesystem
      File.open(filename, 'w') { |f| f.write(header+executable_markup) }

      # add executable filename and interpreter to return array
      ret.push([te_item.id, filename, interpreter])

    }

    # return array of test_execution_id, filename & interpreter
    return ret
  end

  def execute(te_item_id, executable, interpreter='bash')
    te_item = TestExecutionItem.find(te_item_id)
    unless te_item.nil?
      # run command, pass current environment
      te_item.update_attributes(started_at: Time.now, status: EXECUTION_STATUS.key("started"))
      stdout, stderr, exit_status = Open3.capture3(ENV, interpreter, executable)
      te_item.update_attributes(finished_at: Time.now, status: EXECUTION_STATUS.key("finished"))

      # persist status
      exitstatus = exit_status.exitstatus # numeric return code of command
      textstatus = exit_status.success? ? 'succeeded' : 'failed'
      stdout = nil if stdout.blank? # make sure this is nil if there are no stdout contents
      stderr = nil if stderr.blank? # make sure this is nil if there are no stderr contents

      logger.debug "Executed #{interpreter} #{executable}"
      logger.debug "STDOUT: #{stdout}"
      logger.debug "STDERR: #{stderr}"
      logger.info "TestExecutionItem##{te_item.id} (TestExecution##{te_item.test_execution_id}) returned with status: #{textstatus} (exitstatus #{exitstatus})"
      te_item.update_attributes(output: stdout, error: stderr, exitstatus: exitstatus)
    else
      logger.warn("Couldn't execute #{executable}")
    end
  end

end

