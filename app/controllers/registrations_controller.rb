class RegistrationsController < Devise::RegistrationsController

  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
  def update
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      set_flash_message :notice, :updated
      @user.create_activity :update, :owner => current_user
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      #redirect_to after_update_path_for(@user)
      flash[:success] = "Profile updated."
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    redirect_to_anchor_or_back
  end

  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-password
  def update_password
    @user = User.find(current_user.id)
    if @user.update(user_password_params)
      @user.create_activity :update_password, :owner => current_user
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      #redirect_to root_path
      flash[:success] = "Password updated."
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    redirect_to_anchor_or_back
  end


  protected

  # we do not want to provide a confirmation password for user edit/update
  def account_update(resource, params)
    resource.update_without_password(params)
  end

   def user_password_params
    params.required(:user).permit(:password, :password_confirmation)
  end


end