class TestPlansController < ApplicationController
  before_action :authenticate_user!

  def new
    @test_plan = TestPlan.new
    @test_cases = TestCase.all
    @test_scripts = TestScript.all
    @test_suites = TestSuite.all
  end

  def show
    @test_plan = TestPlan.find(params[:id])
    @recent_test_executions = TestExecution.recent
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

  # run TestPlan by creating a new TestExecution
  def run
    tp = TestPlan.find(params[:id])
    te = TestExecution.new
    te.name = "TestExecution of #{tp.name}"
    te.test_plan = tp
    if te.save
      redirect_via_turbolinks_to(test_execution_url(te))
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to :back
    end

  end

  def test_plan_params
    params.require(:test_plan).permit(:name, :description,
                                      {:test_items => [:id, :type]})
  end

end
