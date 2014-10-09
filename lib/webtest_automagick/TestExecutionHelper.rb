# instantiate selenium driver, persist as serialized object (marshall)
# to test within rails console: require 'webtest_automagick/TestExecutionHelper'
#
#
# mydriver = Selenium::WebDriver.for(:remote)
# bridge = mydriver.instance_variable_get(:@bridge).instance_variable_get(:@session_id)
# selenium hub stats: http://localhost:4444/grid/api/testsession?session=6b14f2a6-b9ab-45ea-8b9c-6db5eb974cc0
module WebBrowser

  @@browser_session = 'webdriver.marshall' # filename

  def get_browser_session
    #puts "Getting WebBrowser session..."
    driver = if browser_session_available?
      Marshal.load (File.binread(@@browser_session))
    else
      start
    end
    driver
  end

  def browser_session_available?
    File.exists?(@@browser_session)
  end

  def start
	  #puts "Starting WebBrowser..."
    driver = Selenium::WebDriver.for(:remote)
    File.open(@@browser_session, 'wb') {|f| f.write(Marshal.dump(driver)) }
    driver
  end

  def quit
	  #puts "Quitting WebBrowser..."
  end
end

class TestExecutionHelper
  extend WebBrowser
end
