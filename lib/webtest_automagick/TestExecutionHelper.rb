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

  attr_accessor :browser_session, :random_value
  def initialize
    @random_value = rand(9999)
    @browser_session = "#{Dir.pwd}/#{@random_value}.webdriver.marshall"
  end

  def get_browser_session
    puts "Trying to get existing WebBrowser session..."
    driver =  if browser_session_available?
                puts "Found #{browser_session}! Resuming..."
                Marshal.load(File.binread(@browser_session))
              else
                start
              end
    driver
  end

  def browser_session_available?
    File.exists?(@browser_session)
  end

  def start
	  puts "Starting new WebBrowser session..."
    driver = Selenium::WebDriver.for(:remote)
    File.open(@browser_session, 'wb') {|f| f.write(Marshal.dump(driver)) }
    driver
  end

  def quit
	  puts "Quitting WebBrowser session..."
  end

  def debug_browser_session(driver)

    reread_session = Marshal.load (File.binread(@browser_session))
    puts "Reread Session ID: #{reread_session.session_id}"

    session_id = driver.session_id
    puts "Passed Session ID: #{session_id}"
    uri = URI("http://localhost:4444/grid/api/testsession?session=#{session_id}")
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = false
    headers = Hash.new
    headers['Content-Type'] = 'application/json'
    request = Net::HTTP::Get.new(uri.request_uri, headers)
    response = conn.request(request)
    if response.kind_of? Net::HTTPSuccess
      puts "Hub Status: #{response.body}"
    else
      puts "Failed to fetch selenium hub status from: #{uri.to_s}"
    end
  end
end

class TestExecutionHelper
  include WebBrowser

  def working_dir
    pwd
  end

  def pwd
    Dir.pwd
  end
  alias_method :cwd, :pwd

  def debug
    puts "Working Dir: #{pwd}"
    puts "WebBrowser Session: #{self.instance_variable_get(:@browser_session)}"
    puts "Random: #{self.instance_variable_get(:@random_value)}"
  end

  def get_driver
    begin
      self.get_browser_session
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      puts "Connection refused while trying to get browser session: #{e.message}"
    end
  end

end
