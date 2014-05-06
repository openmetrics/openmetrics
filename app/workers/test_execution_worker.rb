require 'selenium-webdriver'
require 'webtest_automagick'
require 'systemu'

class TestExecutionWorker
  include Sidekiq::Worker
  # queue : use a named queue for this Worker, default 'default'
  # retry : enable the RetryJobs middleware for this Worker, default true. Alternatively, you can specify the max. number of times a job is retried (ie. :retry => 3)
  # backtrace : whether to save any error backtrace in the retry payload to display in web UI, can be true, false or an integer number of lines to save, default false
  sidekiq_options retry: false, backtrace: true
  include WebtestAutomagick

  TMPDIR="#{Rails.root}/tmp/tp" # working dir

  def perform(test_execution_id, test_plan_id)
    tp = TestPlan.find(test_plan_id)
    te = TestExecution.find(test_execution_id)
    te_result = TestExecutionResult.create!(test_execution_id: te.id, result: 'scheduled')
    Dir.exist?(TMPDIR) || system('mkdir', '-p', "#{TMPDIR}")
    # try preparation and execution of testplan
    begin
      t0 = Time.now  #measure duration of preparation & execution
      te_items = prepare(te, tp)
      te_result.update_attributes!(result: 'prepared')
      te_items.each do |tei|
        execute(tei[0], tei[1], tei[2])
      end
      te_result.update_attributes!(duration: Time.now - t0)
      # mark result success if status not yet decided
      te_result.update_attributes!(exitstatus: 0) if te_result.exitstatus.nil?
      # check test execution items for exitstatus indicating a fail
      failed = te.test_execution_items.where(['exitstatus > ?', 0]).order('id')
      te_result.update_attributes!(exitstatus: failed.last.exitstatus) if failed.any?
    rescue Exception => e
      # job preparation or execution failed,
      # use the 'newest' TestExecutionItem exitstatus to mark for overall result:
      logger.warn "preparation or execution of TestExecution##{te.id} thrown exception #{e.message}"
      logger.debug e.backtrace.inspect
    end
    te_result.update_attributes!(result: 'finished')
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

      # create tempfile
      tmpfile = `mktemp -p #{TMPDIR} #{tp.id}_#{n}_#{item.id}.XXXXXX`

      # convert markup
      executable_markup = if item.type == 'TestCase' && item.format == 'selenese'
                            selenese_to_webdriver(item.markup)
                          else
                            item.markup+"\n" # default item.markup
                          end

      # persist as TestExecutionItem
      te_item = TestExecutionItem.create!(markup: header+executable_markup, format: item.format, test_item_id: item.id, test_execution_id: te.id)

      # write executable file to filesystem
      File.open(tmpfile, 'w') { |f| f.write(header+executable_markup) }

      # add executable filename and interpreter to return array
      ret.push([te_item.id, tmpfile, interpreter])

    }

    # return array of test_execution_id, filename & interpreter
    return ret
  end

  def execute(te_item_id, executable, exec_with='bash')
    te_item = TestExecutionItem.find(te_item_id)
    unless te_item.nil?
      # TODO run command with systemu or other ways: we need capture of STDOUT (and probably STDERR) and proper return codes
      # status = systemu cmd, 1=>stdout='', 2=>stderr=''
      status = system(exec_with, executable)
      logger.info "#{executable} returned with status: #{status} (exitstatus #{$?.exitstatus})"

      # TODO for the moment save exit code as strings to :content
      current_output = te_item.output
      new_output = if current_output.nil?
                        "returned status: #{status} (exitstatus #{$?.exitstatus})"
                        else
                          current_output + "; returned status: #{status} (exitstatus #{$?.exitstatus})"
                        end

      te_item.update_attributes!(output: new_output, exitstatus: $?.exitstatus)
    else
      logger.warn("Couldn't execute #{executable}")
    end
  end

end

