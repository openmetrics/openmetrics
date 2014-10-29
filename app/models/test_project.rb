class TestProject < ActiveRecord::Base
  belongs_to :test_plan
  belongs_to :project

  # Scopes
  #
  # all TestProjects that have a TestPlan
  scope :with_test_plans, -> { includes(:test_plan).where.not('test_projects.test_plan_id' => nil).order('test_plans.name')}
end