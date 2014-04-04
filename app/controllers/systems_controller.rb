class SystemsController < ApplicationController
  def index
    @systems = System.all
    respond_with(@systems)
  end
end
