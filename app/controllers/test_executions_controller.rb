require 'reloader/sse' # server side events for execution status

class TestExecutionsController < ApplicationController
  before_action :authenticate_user!
  include ActionController::Live
  helper WebtestsHelper

  def show
    @test_execution = TestExecution.find(params[:id])
    @test_plan = @test_execution.test_plan
    add_breadcrumb 'Test Execution'
  end

  # observe status changes for TestExecution
  def poll
    te = TestExecution.find(params[:id])
    tei = te.test_execution_items

     # SSE expects the `text/event-stream` content type
    response.headers['Content-Type'] = 'text/event-stream'

    sse = Reloader::SSE.new(response.stream)

    begin
      loop do
        status = tei.map{|i| {id: i.id, status: i.status }}
        sse.write({:id => te.id, :status => status, :event => 'executionStatus'})
        sleep 1
      end
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end

  def index
    @test_executions = TestExecution.order("created_at desc")
  end

end
