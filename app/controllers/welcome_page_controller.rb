require 'sidekiq/api' # admin

class WelcomePageController < ApplicationController
  before_filter :authenticate_user!

  def display
    add_breadcrumb 'Home'
    @user = current_user
  end

  def admin
  end

end
