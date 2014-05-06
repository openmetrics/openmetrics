class WebtestsController < ApplicationController
  def index
    @test_plans = TestPlan.all
    @test_cases = TestCase.all
    @recent_test_executions = TestExecution.recent
  end
end
