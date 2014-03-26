class WelcomePageController < ApplicationController

  def display
    @user = current_user
    respond_with @text
  end

end
