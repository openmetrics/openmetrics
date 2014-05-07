class TestExecutionsController < ApplicationController
  before_action :authenticate_user!
  helper WebtestsHelper

  def show
    @test_execution = TestExecution.find(params[:id])
    @test_plan = @test_execution.test_plan
  end

  def index
    @test_executions = TestExecution.order("created_at desc")
  end

end
