class ApplicationController < ActionController::Base

  # first try to authenticate by api_token, then with devise's one
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!

  # PublicActivity make current user available to model to set owner of activity
  #include PublicActivity::StoreController

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # accept & respond to following formats
  respond_to :html, :xml, :js, :json

  # set layout depending on user is authenticated or not
  layout :determine_layout

  # default locale
  before_filter :set_locale

  # configure strong parameters for devise urls
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # stores current location within session[:previous_url]
  before_filter :store_location

  # sessions are lazy loaded, make sure there are breadcrumbs inside
  before_filter :init_breadcrumbs

  # use unobstrusive flash messages https://github.com/leonid-shevtsov/unobtrusive_flash
  after_filter :prepare_unobtrusive_flash

  private

  # using token authentication via 'api_token' parameter. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  # see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
  def authenticate_user_from_token!
    api_token = params[:api_token].presence
    user       = api_token && User.find_by_api_token(api_token.to_s)

    if user
      sign_in user
    end
  end

  def init_breadcrumbs
    session[:breadcrumbs] ||= []
  end

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

  # adds entry for GET requests to user session and cookie
  # number of entries is limited
  #
  # arguments
  # name => link text for breadcrumb entry
  # controller_name => text to complete the title-tag phrase "Go to controller_name name", defaults to nil
  # url => href, defaults to request.url
  def add_breadcrumb name, controller_name = nil, url = request.url
    if !request.get?  # dont set breadcrumb for POST/PUT reqs
      return
    end
    url = eval(url) if url =~ /_path|_url|@/
    if session[:breadcrumbs].size > 6
      session[:breadcrumbs].shift
    end
    session[:breadcrumbs] << [name, controller_name, url] if !session[:breadcrumbs].last or (session[:breadcrumbs].last and session[:breadcrumbs].last[2].to_s != url)
    # breadcrumbs are persisted to cookie aswell, to have them available after relogin
    # => base64 encoded json structure
    cookies[:breadcrumbs] = Base64.encode64(session[:breadcrumbs].to_json)
  end
end
