class UsersController < ApplicationController
  def show
    @user = User.friendly.find(params[:id])
    @activities = PublicActivity::Activity.where(owner_id: @user.id)
  end

  # you may want to look at RegistrationsController for update actions
  def edit
    @user = User.find(params[:id])
  end

end
