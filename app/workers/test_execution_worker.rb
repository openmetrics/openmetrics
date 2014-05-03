require 'selenium-webdriver'
require 'webtest_automagick'
require 'systemu'

class TestExecutionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  include WebtestAutomagick

  TMPDIR="#{Rails.root}/tmp/tp" # working dir

  def perform(testplan_id)
    tp = TestPlan.find(testplan_id)
    Dir.exist?(TMPDIR) || system('mkdir', '-p', "#{TMPDIR}")
    test_execution_items = prepare(tp)
    test_execution_items.each { |tei| execute(tei) }
  end

  # reads test plans test_items and generate executables depending on item format/markup
  def prepare(tp)
    executable_files = []
    items = tp.test_items
    items.each_with_index { |item, n|
      tmpfile = `mktemp -p #{TMPDIR} #{tp.id}_#{n}_#{item.id}.XXXXXX`
      executable_markup = if item.type == 'TestCase' && item.format == 'selenese'
                            selenese_to_webdriver(item.markup)
                          else
                            item.markup # default item.markup
                          end

      # add executable header (shebang) and write to file
      header = ''
      case item.markup
        when 'selense'
          header= %q(#!/usr/bin/env ruby)
        when 'bash'
          header = %q(#!/bin/bash)
      end

      begin
        File.open(tmpfile, 'w') { |f| f.write(header+executable_markup) }
        executable_files.push(tmpfile)
      rescue
        logger.error("Couldn't write executable file")
      end
    }
    return executable_files
  end

  def execute(executable)
    logger.info("executing #{executable.inspect}")
    #cmd = "sh #{executable}"
    #status, stdout, stderr = systemu cmd, 'env'=>{ 'OM_FOO' => "0b101010" }
    status = system('sh', executable)
    logger.info("status: #{status} (#{$?.exitstatus})")
  end

end

