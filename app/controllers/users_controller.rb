class UsersController < ApplicationController
  def show
    @user = User.friendly.find(params[:id])
  end

  # you may want to look at RegistrationsController for update actions
  def edit
    @user = User.find(params[:id])
  end

end
