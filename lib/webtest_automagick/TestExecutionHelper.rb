# instantiate selenium driver, persist as serialized object (marshall)
# to test within rails console: require 'webtest_automagick/TestExecutionHelper'
#
# to get grid session infos:
# mydriver = Selenium::WebDriver.for(:remote)
# bridge = mydriver.instance_variable_get(:@bridge).instance_variable_get(:@session_id) #or
# bridge = mydriver.session_id
# selenium hub stats: http://localhost:4444/grid/api/testsession?session=6b14f2a6-b9ab-45ea-8b9c-6db5eb974cc0
require 'uri' # debug_browser_session
require 'net/http' # debug_browser_session
require 'json' # debug_browser_session
module WebBrowser

  @@browser_session = 'webdriver.marshall' # filename

  def get_browser_session
    #puts "Getting WebBrowser session..."
    driver =  if browser_session_available?
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

  def debug_browser_session(driver)
    session_id = driver.session_id
    puts "Session ID: #{session_id}"
    uri = URI("http://localhost:4444/grid/api/testsession?session=#{session_id}")
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = false
    headers = Hash.new
    headers['Content-Type'] = 'application/json'
    request = Net::HTTP::Get.new(uri.request_uri, headers)
    response = conn.request(request)
    if response.kind_of? Net::HTTPSuccess
      puts response.body
    else
      puts "Failed to fetch selenium hub status from: #{uri.to_s}"
    end
  end
end

class TestExecutionHelper
  extend WebBrowser
end
