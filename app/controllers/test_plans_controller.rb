class TestPlansController < ApplicationController
  before_filter :get_object, only: [:show, :edit, :update, :destroy]
  before_filter :inject_logged_user, only: [:update]

  def edit
    @test_cases = TestCase.all
    @test_scripts = TestScript.all
  end

  def new
    @test_plan = TestPlan.new(base_url: 'http://www.example.com', name: 'My Testplan', user_id: current_user.id)
    @test_cases = TestCase.all
    @test_scripts = TestScript.all
    @test_suites = TestSuite.all
  end

  def show
    @recent_test_executions = TestExecution.recent
    add_breadcrumb @test_plan.name, 'testplan'
  end

  def create
    @test_plan = TestPlan.new(test_plan_params)
    if @test_plan.save
      @test_plan.create_activity :create, :owner => current_user
      flash[:success] = "Test plan saved."
      #redirect_to test_plan_path(@test_plan)
      redirect_via_turbolinks_to(test_plan_path(@test_plan))
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to_anchor_or_back
    end

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
    detect_changes
    if @test_plan.update_attributes!(test_plan_params)
      inject_logged_user
      changes = Secretary::Version.where(versioned_type: 'TestPlan', versioned_id: @test_plan.id, user_id: current_user.id)
      activity_params = if changes.any? and attr_changed?
                          last_change = changes.last
                          { :description => last_change.description, :changes => last_change.object_changes }
                        else
                          {}
                        end

      @test_plan.create_activity :update, :owner => current_user, :parameters => activity_params
      flash[:success] = 'Test Plan was successfully updated.'
    else
      flash[:warn] = "Oh snap! That didn't work."
    end
    redirect_via_turbolinks_to :back
  end

  def destroy
    if @test_plan.destroy
      flash[:notice] = "Successfully destroyed Test Plan."
      redirect_to :action => "index", :controller => 'webtests'
    else
      flash[:error] = 'Failed to delete system.'
    end
  end


  private

  def get_object
    @test_plan = TestPlan.friendly.find(params[:id])
  end

  def test_plan_params
    params.require(:test_plan).permit(:name, :description, :base_url,
                                      test_plan_items_attributes: [:id, :_destroy, :test_item_id, :position],
                                      quality_criteria_attributes: [:id, :_destroy, :entity_id, :entity_type, :attr, :operator, :value, :unit]
    )
  end

  # save user_id within model changes
  # https://github.com/SCPR/secretary-rails#tracking-users
  def inject_logged_user
    @test_plan.logged_user_id = current_user.id
  end

  def detect_changes
    @changed = []
    test_plan_params.each do |param|
      p_name = param[0]
      p_value = param[1]
      next if p_value.is_a? Hash # TODO detect changes to running_services and running_collectd_plugins aswell
      @changed << p_name if @test_plan.send(p_name) != p_value
    end

  end

  def attr_changed?
    @changed.any?
  end

end
