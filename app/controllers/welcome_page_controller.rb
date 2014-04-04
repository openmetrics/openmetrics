class WelcomePageController < ApplicationController

  before_filter :authenticate_user!

  def display
    @user = current_user
    respond_with @text
  end

end
