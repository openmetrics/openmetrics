class TestPlansController < ApplicationController
  before_action :authenticate_user!

  def edit
    @test_plan = TestPlan.friendly.find(params[:id])
  end

  def new
    @test_plan = TestPlan.new(base_url: 'http://www.example.com', name: 'My Testplan', user_id: current_user.id)
    @test_cases = TestCase.all
    @test_scripts = TestScript.all
    @test_suites = TestSuite.all
  end

  def show
    @test_plan = TestPlan.friendly.find(params[:id])
    @recent_test_executions = TestExecution.recent
    add_breadcrumb @test_plan.name, 'testplan'
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
    te.test_plan = tp
    if te.save
      redirect_via_turbolinks_to(test_execution_url(te))
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to :back
    end

  end

  def update
    @test_plan = TestPlan.find(params[:id])
    if @test_plan.update_attributes(test_plan_params)
      @test_plan.create_activity :update, owner: current_user
      redirect_to @test_plan, notice: 'Upload was successfully updated.'
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to @test_plan
    end
  end

  private
  def test_plan_params
    params.require(:test_plan).permit(:name, :description, :base_url,
                                      {:test_items => [:id, :type]})
  end

end
