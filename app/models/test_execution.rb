# == Schema Information
#
# Table name: test_executions
#
#  id           :integer          not null, primary key
#  test_plan_id :integer
#  user_id      :integer
#  status       :integer
#  created_at   :datetime
#  updated_at   :datetime
#  job_id       :string(255)
#  base_url     :string(255)
#  started_at   :datetime
#  finished_at  :datetime
#

class TestExecution < ActiveRecord::Base
  include Executable
  include Qualified
  include Trackable

  belongs_to :test_plan

  # TestExecutionItem belongs to TestExecution, but we currently use method test_execution_items
  # has_many :test_execution_items

  # overall result and quality
  has_one :test_execution_result

  # most recent test executions
  scope :recent, ->(num=5) { order('created_at DESC').limit(num) }

  def result
    self.test_execution_result
  end

  def test_execution_items
    TestExecutionItem.where(test_execution_id: self.id).order('id')
  end

  # used for navigation within views
  def next
    self.class.where("id > ?", id).first
  end

  # used for navigation within views
  def previous
    self.class.where("id < ?", id).last
  end

  # get quality criteria of corresponding test_plan and all it's test_items (by test_plan_item relation)
  def quality_criteria
    self.test_plan.quality_criteria.flatten | self.test_plan.test_plan_items.collect{ |tpi| tpi.quality_criteria }.flatten
  end


end
