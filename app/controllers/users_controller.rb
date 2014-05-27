class UsersController < ApplicationController
   before_action :authenticate_user!

  def show
    @user = User.friendly.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

end
