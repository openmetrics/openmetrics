class TestProject < ActiveRecord::Base
  belongs_to :test_plan
  scope :with_test_plans, where.not(:test_plan_id => nil).order('name ASC')
  belongs_to :project
end