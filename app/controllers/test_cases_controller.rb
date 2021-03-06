class TestCasesController < ApplicationController
  helper WebtestsHelper

  def index
    @test_cases = TestCase.all
  end

  def show
    @test_case = TestCase.find(params[:id])
  end

  def new
    @test_case = TestCase.new(name: 'unholy exit', description: 'perform a noop and exit with a non-successful return code', format: 'bash', markup: ": && exit42")
  end

  def create
    @test_case = TestCase.new(test_case_params)
    if @test_case.save
      flash[:success] = "Test case saved."
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    # redirect_to :back
    redirect_via_turbolinks_to(test_case_path(@test_case))
  end

  def edit
    @test_case = TestCase.find(params[:id])
  end

  def update
    @test_case = TestCase.find(params[:id])
    if @test_case.update!(test_case_params)
      flash[:success] = "Test case updated."
    else
      flash[:warn] = 'Something went wrong while updating test case.'
    end
    # redirect_to :back
    redirect_via_turbolinks_to(:back)
  end

  def destroy
    @test_case = TestCase.find(params[:id])
    if @test_case.destroy!
      flash[:success] = "Test case deleted."
    end
    redirect_to :back
  end

  private
  # Using a private method to encapsulate the permissible parameters
  # is just a good pattern since you'll be able to reuse the same
  # permit list between create and update. Also, you can specialize
  # this method with per-user checking of permissible attributes.
  def test_case_params
    params.require(:test_case).permit(:name, :description, :markup, :format)
  end
end
