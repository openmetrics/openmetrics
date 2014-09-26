module WebBrowser

  def get_browser_session
    puts "Getting WebBrowser session..."
  end

  def ensure_started
    puts "Ensure that WebBrowser is started..."
  end

  def start
	  puts "Starting WebBrowser..."
  end

  def quit
	  puts "Quitting WebBrowser..."
  end
end

class TestExecutionHelper
  extend WebBrowser
end
