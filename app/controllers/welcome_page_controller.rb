require 'sidekiq/api' # admin

class WelcomePageController < ApplicationController
  before_filter :authenticate_user!

  def display
    @user = current_user
    @recent_test_executions = TestExecution.order('created_at desc').limit(5)
  end

  def admin
  end

end
