class WebtestsController < ApplicationController
  def index
    @test_plan = TestPlan.new
    @test_cases = TestCase.all
    @test_suites = TestSuite.all
  end

  def new
  end
end
