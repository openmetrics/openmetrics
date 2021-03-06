class WebtestsController < ApplicationController
  def index
    add_breadcrumb 'Test Center'
    @test_plans = TestPlan.all
    @test_cases = TestCase.all
    @test_scripts = TestScript.all
    @recent_test_executions = TestExecution.recent
  end
end
