class TestExecutionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @test_execution = TestExecution.find(params[:id])
    @test_plan = @test_execution.test_plan
  end

end
