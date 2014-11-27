# override some methods, e.g. to prevent flash notices (http://stackoverflow.com/questions/5762798/rails-disable-devise-flash-messages)
class SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super
    flash.delete(:notice)
  end

  # DELETE /resource/sign_out
  def destroy
    super
    flash.delete(:notice)
  end
end
