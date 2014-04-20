require 'nokogiri'

module WebtestAutomagick


  public

  # translates selenese to ruby-webdriver
  # http://release.seleniumhq.org/selenium-core/1.0.1/reference.html
  def selenese_to_webdriver(markup)
    #doc = Nokogiri::HTML(open("/tmp/tc1.html"))
    doc = Nokogiri::HTML(markup)
    title = doc.css('title').text
    sel_commands = []
    doc.css("tbody tr").each do |x|
      command = x.css("td")[0].text
      target = x.css("td")[1].text
      value = x.css("td")[2].text
      sel_commands.push([command, target, value])
    end

    p sel_commands
    sel_commands
  end

end