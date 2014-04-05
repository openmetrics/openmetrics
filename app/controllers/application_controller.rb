class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # accept & respond to following formats
  respond_to :html, :xml, :json

  # set layout depending on user is authenticated or not
  layout :determine_layout

  # default locale
  before_filter :set_locale

  # configure strong parameters for devise urls
  before_filter :configure_permitted_parameters, if: :devise_controller?

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    Rails.application.routes.default_url_options[:locale]= I18n.locale
  end

  def determine_layout
    current_user ? "application" : "startpage"
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
end
