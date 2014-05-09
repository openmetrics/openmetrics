require 'nokogiri'

module WebtestAutomagick


  public

  # translates selenese to ruby-webdriver
  # http://release.seleniumhq.org/selenium-core/1.0.1/reference.html
  def selenese_to_webdriver(markup, base_url)
    #doc = Nokogiri::HTML(open("/tmp/tc1.html"))
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

    # prepare head
    wd += %Q[
require "selenium-webdriver"
driver = Selenium::WebDriver.for :firefox
driver.navigate.to "#{base_url}"
]

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
        when /^\/{2}(.*)/ # xpath shortcut '//'
          how = ':xpath'
          what = $1
        when /^xpath=(.*)/
          how = ':xpath'
          what = $1
        when /^id(entifier)?=(.*)/
          how = ':id'
          what = $2
      end

      # translate selenese commands to selenium-webdriver markup
      # see http://selenium.googlecode.com/git/docs/api/rb/Selenium/Client/GeneratedDriver.html
      wd << "\n\n# DEBUG #{command}|#{target}|#{value}\n"
      case command
        when /click|clickAndWait/
          wd += "driver.find_element(#{how}, \"#{what}\").click\n"
        when /open/
          wd << "driver.get(\"#{base_url}#{target}\")\n"
        when /type/
          wd += "driver.find_element(#{how}, \"#{what}\").send_keys(\"#{value}\")\n"
        when /waitForElementPresent/
          wd += '# wait for a specific element to show up' + "\n"
          wd += 'wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds' + "\n"
          wd += "wait.until { driver.find_element(#{how}, \"#{what}\") } \n"
      end
    end
    wd += "driver.quit"
    wd
  end
end