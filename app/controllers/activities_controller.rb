class ActivitiesController < ApplicationController
  def index
    add_breadcrumb 'Activities'
    @activities = PublicActivity::Activity.order('created_at desc')
  end
end
