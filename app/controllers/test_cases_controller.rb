class TestCasesController < ApplicationController
  def new
    @test_case = TestCase.new
  end

  def edit
    @test_case = TestCase.find(params[:id])
  end

  def update
    test_case = TestCase.find(params[:id])
    if test_case.update!(test_case_params)
      flash[:success] = "Test case updated."
    else
      flash[:warn] = 'Something went wrong while updating test case.'
    end
    redirect_to :back
  end

  private
  # Using a private method to encapsulate the permissible parameters
  # is just a good pattern since you'll be able to reuse the same
  # permit list between create and update. Also, you can specialize
  # this method with per-user checking of permissible attributes.
  def test_case_params
    params.require(:test_case).permit(:name, :description, :markup)
  end
end
