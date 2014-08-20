require 'sidekiq/api' # admin

class WelcomePageController < ApplicationController
  def display
    add_breadcrumb 'Home'
    @user = current_user
  end

  def admin
  end

end
