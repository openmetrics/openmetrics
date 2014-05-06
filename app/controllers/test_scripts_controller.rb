class TestScriptsController < ApplicationController
  before_action :authenticate_user!
  helper WebtestsHelper

  def index
    @test_scripts = TestScript.all
  end

  def show
    @test_script = TestScript.find(params[:id])
  end

  def new
    @test_script = TestScript.new(name: 'unholy exit', description: 'perform a noop and exit with a non-successful return code', format: 'bash', markup: ": && exit42")
    @upload = Upload.new # for file upload
  end

  def create
    @test_script = TestScript.new(test_script_params)
    if @test_script.save
      flash[:success] = "Test script saved."
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    redirect_to :back
  end

  def destroy
    @test_script = TestScript.find(params[:id])
    if @test_script.destroy!
      flash[:success] = "Test script deleted."
    end
    redirect_to :back
  end

  private
  # Using a private method to encapsulate the permissible parameters
  # is just a good pattern since you'll be able to reuse the same
  # permit list between create and update. Also, you can specialize
  # this method with per-user checking of permissible attributes.
  def test_script_params
    params.require(:test_script).permit(:name, :description, :markup, :format)
  end
end
