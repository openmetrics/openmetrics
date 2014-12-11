require 'nokogiri'
require 'fileutils'

module WebtestAutomagick


  public

  # copies some libs to execution dir
  def self.setup_execution_helper(dir)
    #puts "Trying to create #{dir}/lib"
    FileUtils.mkdir("#{dir}/lib") unless Dir.exist?("#{dir}/lib")
    FileUtils.cp("#{Rails.root.join('lib', 'webtest_automagick').to_s}/TestExecutionHelper.rb", "#{dir}/lib")
  end

  def self.random_input_generator(test_item)
    rb=''
rb += %Q[
require_relative 'lib/TestExecutionHelper'

helper = TestExecutionHelper.new
]
    rb += test_item.markup
    # append newline to make humans interacting via terminals happy
    rb+="\n" unless test_item.markup.ends_with? "\n"
    input_vars_array = test_item.provided_input.collect{ |x| x.first }
    # Array -> String List http://stackoverflow.com/questions/3500814/ruby-array-to-string-conversion
    rb += "helper.store_environment! #{input_vars_array.map{ |i|  %Q('#{i}') }.join(',')}\n"
    rb
  end

  # translates selenese to ruby-webdriver
  # http://release.seleniumhq.org/selenium-core/1.0.1/reference.html
  def self.selenese_to_webdriver(markup, base_url, start_browser=false, close_browser=false)
    doc = Nokogiri::HTML(markup)

    # extract title
    title = doc.css('title').text

    # extract base url from test case if not set
    if base_url.nil?
      base_url=''
      if doc.xpath "//link[@rel='selenium.base']"
        base_url = doc.xpath("//link[@rel='selenium.base']").attribute("href").value
      end
    end

    # remove trailing slash from base_url
    if base_url.ends_with? '/'
      base_url.gsub!(/\/$/, '') #remove trailing slash
    end

    # extract selenese commands
    sel_commands = []
    doc.css("tbody tr").each do |x|
      command = x.css("td")[0].text
      target = x.css("td")[1].text
      value = x.css("td")[2].text
      sel_commands.push([command, target, value])
    end

    wd='' #webdriver markup


wd += %Q[
require 'selenium-webdriver'
include Selenium::WebDriver::Keys
require 'test/unit/assertions'
include Test::Unit::Assertions
require_relative 'lib/TestExecutionHelper'

helper = TestExecutionHelper.new
driver = helper.get_driver
# uncomment to print some debug info
#helper.debug
driver.manage.timeouts.page_load = 20 # page load timeout in seconds
driver.manage.timeouts.implicit_wait = 10 # seconds An implicit wait is to tell WebDriver to poll the DOM for a certain amount of time when trying to find an element or elements if they are not immediately available. The default setting is 0.
]
    wd+="driver.navigate.to \"#{base_url}\"\n" if start_browser

    sel_commands.each do |command, target, value|

      # decide strategy for element locator
      # see http://selenium.googlecode.com/git/ide/main/src/content/selenium-core/reference.html#locators
      # and http://rubydoc.info/gems/selenium-webdriver/0.0.28/Selenium/WebDriver/Find for
      # Without an explicit locator prefix, Selenium uses the following default strategies:
      # dom, for locators starting with "document."
      # xpath, for locators starting with "//"
      # identifier, otherwise
      how=':id' #set default behavior
      what=target #set default behavior
      case target
        when /^css=(.*)/
          how = ':css'
          what = $1
        when /^link=(.*)/
          how = ':link'
          what = $1
        when /^name=(.*)/
          how = ':name'
          what = $1
        when /^(\/{2}.*)/ # xpath shortcut '//'
          how = ':xpath'
          what = $1
        when /^xpath=(.*)/
          how = ':xpath'
          what = $1
        when /^id(entifier)?=(.*)/
          how = ':id'
          what = $2
      end

      # if value is of format ${foo} reference to its environment variable ENV['foo'] instead
      # do the same with target (on echo command)
      unless (value =~ /\$\{[a-zA-Z0-9_]*\}/).nil?
        value.gsub!(/\$\{([a-zA-Z0-9_]*)\}/, '#{ENV[\'\1\']}')
      end
      unless (target =~ /\$\{[a-zA-Z0-9_]*\}/).nil? and command == 'echo'
        target.gsub!(/\$\{([a-zA-Z0-9_]*)\}/, '#{ENV[\'\1\']}')
      end

      # translate selenese commands to selenium-webdriver markup
      # see http://selenium.googlecode.com/git/docs/api/rb/Selenium/Client/GeneratedDriver.html
      #wd << "\n\n# DEBUG #{command}|#{target}|#{value}\n"
      if target.empty? and value.empty?
        # it's a comment
        wd << '# '+ command + "\n"
      else
        case command
          when /click|clickAndWait/
            wd << "driver.find_element(#{how}, \"#{what}\").click\n"
          when /echo/
            wd << "puts \"#{html_escape(target)}\"\n"
          when /keyPress|keyPressAndWait/
            wd << '# press key and wait' + "\n"
            #wd << 'wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds' + "\n"
            # see http://code.google.com/p/selenium/source/browse/rb/lib/selenium/webdriver/common/action_builder.rb for action details
            # see http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Keys.html for possible keys
            # Map Keys for keyPress, keyPressAndWait etc.
            # Either Key may be a string("\" followed by the numeric keycode of the key to be pressed, normally the ASCII value of that key),
            # or a single character. For example: "w", "\119".
            if value =~ /^\\/
              case value
                when '\13'
                  key = 'Selenium::WebDriver::Keys[:return]'
                else
                  key = 'FIXME unknown key'
              end
            end
            wd << "driver.find_element(#{how}, \"#{what}\").send_keys(#{key})\n"
          when /open/
            wd << "driver.get(\"#{base_url}#{target}\")\n"
          when /pause/
            # selenese command uses miliseconds, whereas ruby sleep uses seconds
            s = target.to_f/1000
            wd << "sleep #{s}\n"
          when /^store$/
            wd << "ENV['#{value}'] = '#{target}'\n"
          when /storeText/
            wd << "text = driver.find_element(#{how}, \"#{what}\").text\n"
            wd << "ENV['#{value}'] = text\n"
          when /type/
            wd << "driver.find_element(#{how}, \"#{what}\").send_keys(\"#{value}\")\n"
          when /verifyElementPresent/
            wd << "assert(driver.find_element(#{how}, \"#{what}\"), \"verifyElementPresent '#{target}' failed\") \n"
          when /^verifyText$/
            wd << "assert_equal(\"#{value}\", driver.find_element(#{how}, \"#{what}\").text, \"verifyText failed\") \n"
          when /^verifyTextPresent$/
            wd << "assert(driver.page_source.include?(\"#{target}\"), \"verifyTextPresent '#{target}' failed\")\n"
          when /^verifyTextNotPresent$/
            wd << "assert(!driver.page_source.include?(\"#{target}\"), \"verifyTextNotPresent '#{target}' failed\")\n"
          when /waitForElementPresent/
            wd << '# wait for a specific element to show up' + "\n"
            wd << 'wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds' + "\n"
            wd << "wait.until { driver.find_element(#{how}, \"#{what}\") } \n"
          else
            wd << "# unimplemented command: #{command}|#{target}|#{value}\n"
            wd << "exit 42\n"
        end
      end
    end
    wd << "driver.quit\n" if close_browser
    wd << "helper.quit\n" if close_browser
    wd
  end

  # looks out for 'store' commands with it's (name and value) in selenese markup
  # returns array of found input pairs
  def self.selenese_extract_input(markup)
    doc = Nokogiri::HTML(markup)
    store_commands = []
    doc.css("tbody tr").each do |x|
      command = x.css("td")[0].text
      var_value = x.css("td")[1].text
      var_name = x.css("td")[2].text
      store_commands.push([var_name, var_value]) if command == 'store'
    end
    return store_commands
  end

  # find selenese variable references, e.g. ${foo}
  # returns array of command, target and value
  def self.selenese_input_references(markup)
    doc = Nokogiri::HTML(markup)
    var_commands = []
    doc.css("tbody tr").each do |x|
      command = x.css("td")[0].text
      target = x.css("td")[1].text
      value = x.css("td")[2].text
      if target.scan(/\$\{[a-zA-Z0-9]*\}/).any?
         var_commands.push(target.scan(/\$\{([a-zA-Z0-9]*)\}/))
      end
      if value.scan(/\$\{[a-zA-Z0-9]*\}/).any?
        var_commands.push(value.scan(/\$\{([a-zA-Z0-9]*)\}/))
      end
    end
    return var_commands
  end

  # looks for stored ENV vars
  # two formats are valid: ENV['<name>'] = <value> and ENV.store('<name>', <value>)
  # returns array of found input pairs
  def self.ruby_extract_input(markup)
    store_commands = []
    env_var_matches = markup.scan(/ENV\[['"]([a-zA-Z0-9]+)['"]\]/) # matches password from ENV['password']
    env_var_matches.each do |match|
      store_commands.push([match.first, nil])
    end
    return store_commands
  end

  # looks for stored ENV vars
  # two formats are valid: ENV['<name>'] = <value> and ENV.store('<name>', <value>)
  # returns array of found input pairs
  def self.ruby_extract_input_from_file(path_to_file)
    store_commands = []
    if File.file?(path_to_file)
      File.foreach(path_to_file).with_index { |line, line_num|
        #puts "#{line_num}: #{line}"
        var_name = line.split('=')[0]
        var_value = line.match(/^.+=['"]?(.[^'"]+)['"]?/)[1] # first match from MatchData
        store_commands.push([var_name, var_value])
      }
    end
    store_commands
  end
end