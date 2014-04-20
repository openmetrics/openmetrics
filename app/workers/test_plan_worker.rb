require 'selenium-webdriver'
require 'webtest_automagick'

class TestPlanWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  include WebtestAutomagick

  TMPDIR="#{Rails.root}/tmp/tp" # working dir

  def perform(testplan_id)
    tp = TestPlan.find(testplan_id)
    #run_test_plan1
    Dir.exist?(TMPDIR) || system('mkdir', '-p', "#{TMPDIR}")
    test_exectution_items = prepare(tp)
    #scan_services!(target)
  end

  # reads test plans test_items and generate executables depending on item format/markup
  def prepare(tp)
    items = tp.test_items
    items.each_with_index { |item, n|
      tmpfile = ` mktemp -p #{TMPDIR} #{tp.id}_#{n}_#{item.id}.XXXXXX`
      executable_markup = if item.type == 'TestCase' && item.format == 'selenese'
                            selenese_to_webdriver(item.markup)
                          else
                            item.markup # default item.markup
                          end

      File.open(tmpfile, 'w') { |f| f.write(executable_markup) }
    }
  end

  def run_test_plan1

    begin
      driver = Selenium::WebDriver.for :firefox
      driver.navigate.to "http://google.com"

      element = driver.find_element(:name, 'q')
      element.send_keys "Hello WebDriver!"
      element.submit

      logger.info('Title: ' + driver.title)
    ensure
      driver.quit
    end
  end

end

