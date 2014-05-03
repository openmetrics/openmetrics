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

  # stores current location within session[:previous_url]
  before_filter :store_location

  # use unobstrusive flash messages https://github.com/leonid-shevtsov/unobtrusive_flash
  after_filter :prepare_unobtrusive_flash

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    # appends _locale=<locale> parameter to url
    #Rails.application.routes.default_url_options[:locale]= I18n.locale
  end

  def determine_layout
    current_user ? "application" : "startpage"
  end

  # store last url - this is needed for post-login redirect to whatever the user last visited.
  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  def store_location
    if  request.fullpath != "/users/sign_in" &&
        request.fullpath != "/users/sign_up" &&
        request.fullpath != "/users/password" &&
        request.fullpath != "/users/sign_out" &&
        !request.xhr? && # don't store ajax calls
        request.get? # only store GET requests (no POST, PUT, DELETE, ...)
      session[:previous_url] = request.fullpath
    end
  end

  # after sign-in redirect back to previous url (bounce-back after login)
  # http://rubydoc.info/github/plataformatec/devise/master/Devise/Controllers/Helpers:after_sign_in_path_for
  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end


  # this useful in conjunction with formbakery's :within_tab option, it may append a hidden input field to make redirects
  # to specific ui tab possible, e.g. to /systems/new#file-upload
  def redirect_to_anchor_or_back
    if params[:anchor]
      redirect_to session[:previous_url]+params[:anchor]
    else
      redirect_to :back
    end

  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
end
