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
require 'yaml' # debug_browser_session
module WebBrowser

  attr_accessor :browser_session, :random_value
  def initialize
    @random_value = rand(9999)
    @browser_session_file = "#{Dir.pwd}/webdriver.yml"
  end

  def get_browser_session
    driver =  if browser_session_available?
                #puts "Found resumeable WebBrowser session!"
                #puts "Loading from File #{@browser_session_file} #{File.lstat(@browser_session_file).inspect}"
                #puts "Random: #{@random_value}"
                YAML.load(File.read(@browser_session_file))
              else
                start
              end
    #debug_browser_session(driver)
    driver
  end

  def browser_session_available?
    File.exists?(@browser_session_file)
  end

  def start
    #puts "Starting new WebBrowser session."
    driver = Selenium::WebDriver.for(:remote)
    File.open(@browser_session_file, 'w') {|f| f.write(YAML.dump(driver)) }
    #puts "Writing to File #{File.lstat(@browser_session_file).inspect}"
    #puts "Random: #{@random_value}"
    driver
  end

  # remove serialized browser file
  def cleanup_browser
    File.delete(@browser_session_file)
  end

  # polls session status from grid hub
  def debug_browser_session(driver)
    bridge = driver.instance_variable_get(:@bridge)
    session_id = bridge.instance_variable_get(:@session_id)
    puts "Hub Session ID: #{session_id}"
    puts "Browser: #{bridge.instance_variable_get(:@browser).to_s}"
    #puts "Server Uri:#{bridge.instance_variable_get("@http").instance_variable_get("@server_url").to_s}"
    puts "HTTP: #{bridge.instance_variable_get(:@http).inspect}"
    #puts "Capabilities: #{bridge.instance_variable_get(:@capabilities).inspect}"

    # cookies
    puts "Cookies: "
    if driver.manage.all_cookies.any?
      driver.manage.all_cookies.each do |cookie|
        puts cookie.inspect
      end
    else
      puts "none"
    end

    # poll status from hub
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

  def initialize
    super
  end

  def pwd
    Dir.pwd
  end
  alias_method :cwd, :pwd
  alias_method :working_dir, :pwd

  def program_name
    #puts __FILE__ # /home/mgrobelin/development/openmetrics/tmp/test_executions/13/lib/TestExecutionHelper.rb
    #puts File.dirname(__FILE__) # /home/mgrobelin/development/openmetrics/tmp/test_executions/13/lib
    #puts File.basename(__FILE__) # TestExecutionHelper.rb
    #puts $0 # /home/mgrobelin/development/openmetrics/tmp/test_executions/13/1_40501189.rb
    #puts File.basename($0) # 1_40501189.rb
    File.basename($0)
  end
  alias_method :script_name, :program_name

  def debug
    puts "Current Working Dir: #{pwd}"
    puts "Program Name: #{program_name}"
    puts "WebBrowser Session File: #{self.instance_variable_get(:@browser_session_file)}"
    puts "Random: #{self.instance_variable_get(:@random_value)}"
  end

  def get_driver
    begin
      self.get_browser_session
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      puts "Connection refused while trying to get browser session: #{e.message}"
    end
  end

  def store_environment!(*var_names)
    in_dir = "#{pwd}/in"
    item_id = self.program_name.split('.')[0].split('_')[1] # e.g. 2_23423423.rb
    position = self.program_name.split('_')[0] # e.g. 2_23423423.rb
    Dir.mkdir(in_dir) unless Dir.exist?(in_dir)
    bash_env = ''
    var_names.each do |var_name|
        if ENV["#{var_name}"] == nil
          bash_env += "#{var_name}=':'\n" # : means something like nothing in bash
        else
          bash_env += "#{var_name}='#{ENV["#{var_name}"]}'\n"
        end
    end
    File.open(in_dir+"/#{position}_#{item_id}.env", 'w') {|f| f.write(bash_env) }
  end
  alias_method :store_environment, :store_environment!

  def quit_driver
    self.cleanup_browser
  end
  alias_method :quit, :quit_driver
  alias_method :cleanup, :quit_driver

end
