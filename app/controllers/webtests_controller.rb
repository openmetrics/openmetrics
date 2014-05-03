class WebtestsController < ApplicationController
  def index
    @test_plans = TestPlan.all # temp. show all webtests
    @test_plan = TestPlan.new
    @test_cases = TestCase.all
    @test_scripts = TestScript.all
    @test_suites = TestSuite.all
  end
end
