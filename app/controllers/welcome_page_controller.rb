require 'sidekiq/api' # admin

class WelcomePageController < ApplicationController
  before_filter :authenticate_user!

  def display
    @user = current_user
  end

  def admin
  end

end
