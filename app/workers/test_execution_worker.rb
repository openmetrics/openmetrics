require 'selenium-webdriver'
require 'webtest_automagick'
require 'systemu'

class TestExecutionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  include WebtestAutomagick

  TMPDIR="#{Rails.root}/tmp/tp" # working dir

  def perform(test_execution_id, test_plan_id)
    tp = TestPlan.find(test_plan_id)
    te = TestExecution.find(test_execution_id)
    result = TestExecutionResult.create!(test_execution: te)
    Dir.exist?(TMPDIR) || system('mkdir', '-p', "#{TMPDIR}")
    test_execution_items = prepare(tp)
    t0 = Time.now  #measure duration of execution
    test_execution_items.each do |tei|
      execute(tei[0],tei[1], result)
    end
    result.update_attributes!(duration: Time.now - t0)
  end

  # reads test plans test_items and generate executables depending on item format/markup
  # returns pairs of arrays (filename, interpreter)
  def prepare(tp)
    ret = []
    items = tp.test_items
    items.each_with_index { |item, n|

      #  executable header (shebang) and extension
      header = ""
      exec = ""
      case item.format
        when 'selenese'
          header = "#!/usr/bin/env ruby\n"
          exec = "ruby"
        when 'bash'
          header = "#!/bin/bash\n"
          exec = "bash"
      end

      # create tempfile
      tmpfile = `mktemp -p #{TMPDIR} #{tp.id}_#{n}_#{item.id}.XXXXXX`

      # convert markup
      executable_markup = if item.type == 'TestCase' && item.format == 'selenese'
                            selenese_to_webdriver(item.markup)
                          else
                            item.markup # default item.markup
                          end

      # write executable file
      begin
        File.open(tmpfile, 'w') { |f| f.write(header+executable_markup) }
        ret.push([tmpfile, exec]) #return object
      rescue
        logger.error("Couldn't write executable file")
      end
    }
    ret
  end

  def execute(executable, exec_with='bash', result)
    logger.info("executing #{executable.inspect} with #{exec_with}")
    cmd = "#{exec_with} #{executable}"
    # run command with systemu, capture stdout and stderr
    # status = systemu cmd, 1=>stdout='', 2=>stderr=''
    status = system(exec_with, executable)
    logger.info("returned status: #{status} (exitstatus #{$?.exitstatus})")
    result.output=status
    #result.output = old_output.nil? ? stdout : old_output + stdout
    result.exitstatus = $?.exitstatus
    result.save
  end

end

