require 'reloader/sse' # server side events for execution status

class TestExecutionsController < ApplicationController
  include ActionController::Live
  helper WebtestsHelper

  def show
    @test_execution = TestExecution.find(params[:id])
    @test_plan = @test_execution.test_plan
    add_breadcrumb 'Test Execution'
  end

  # observe status changes for TestExecution ans push via sse
  # http://tx.pignata.com/2012/10/building-real-time-web-applications-with-server-sent-events.html
  # http://tenderlovemaking.com/2012/07/30/is-it-live.html
  # def poll
  #   te = TestExecution.find(params[:id])
  #   tei = te.test_execution_items
  #
  #    # SSE expects the `text/event-stream` content type
  #   response.headers['Content-Type'] = 'text/event-stream'
  #
  #   sse = Reloader::SSE.new(response.stream)
  #
  #   begin
  #     loop do
  #       status = tei.map{|i| {id: i.id, status: i.status }}
  #       sse.write({:id => te.id, :status => status, :event => 'executionStatus'})
  #       sleep 1
  #     end
  #   rescue IOError
  #     # When the client disconnects, we'll get an IOError on write
  #   ensure
  #     sse.close
  #   end
  # end
  #

  # usual ajax polling
  def poll
    te = TestExecution.find(params[:id])
    tei = te.test_execution_items
    status = tei.map{|i| {id: i.id, status: i.status }}
    render json: { :id => te.id, status: te.status, :steps => status }
  end

  def index
    @test_executions = TestExecution.order("created_at desc")
  end

end
