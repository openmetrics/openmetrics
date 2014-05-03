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
    test_execution_items.each{ |tei| execute(tei[0],tei[1]) }
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
        ret.push([tmpfile, exec])
      rescue
        logger.error("Couldn't write executable file")
      end
    }
    ret
  end

  def execute(executable, exec_with='bash')
    logger.info("executing #{executable.inspect}")
    #cmd = "sh #{executable}"
    #status, stdout, stderr = systemu cmd, 'env'=>{ 'OM_FOO' => "0b101010" }
    status = system(exec_with, executable)
    logger.info("status: #{status} (#{$?.exitstatus})")
  end

end

