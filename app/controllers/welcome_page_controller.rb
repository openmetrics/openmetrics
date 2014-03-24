class WelcomePageController < ApplicationController

  def display
    @text = "Hello from WelcomePageController!"
    respond_with @text
  end

end
