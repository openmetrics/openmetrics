class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # accept & respond to following formats
  respond_to :html, :xml, :json

  # set layout depending on user is authenticated or not
  layout :determine_layout

  private
  def determine_layout
    current_user ? "application" : "startpage"
  end
end
