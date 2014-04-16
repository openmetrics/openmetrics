class TestPlanWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    run_test_plan1
    #scan_services!(target)
  end

  def run_test_plan1
    require "selenium-webdriver"

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

