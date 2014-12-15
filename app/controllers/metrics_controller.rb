class MetricsController < ApplicationController
  before_filter :get_object, only: [:show]

  def show
    add_breadcrumb @metric.name, 'metric'
  end

  def index
    add_breadcrumb 'Metric List'
    @metrics = Metric.all
  end

  private

  def get_object
    @metric = Metric.find(params[:id])
  end

end
