     class TestPlansController < ApplicationController
  before_action :authenticate_user!

  def show
    @test_plan = TestPlan.find(params[:id])
  end

  def create
    @test_plan = TestPlan.new(test_plan_params)
    if @test_plan.save
      flash[:success] = "Test plan saved."
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    redirect_to :back
  end

  def run
    flash[:success] = "Test plan saved."
    tp = TestPlan.find(params[:id])
    te = TestExecution.new
    te.name = "TestExecution of #{tp.name}"
    te.test_plan = tp
    te.save ? flash[:success] = "Test plan saved." : flash[:warn] = "Oh snap! That didn't work."
    redirect_to :back
  end

  def test_plan_params
    params.require(:test_plan).permit(:name, :description,
                                      {:test_items => [:id, :type]})
  end

end
