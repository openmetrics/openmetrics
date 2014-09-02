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

  belongs_to :test_plan
  # TestExecutionItem belongs to TestExecution, but we currently use method test_execution_items
  # has_many :test_execution_items
  has_one :test_execution_result

  # most recent test executions
  scope :recent, ->(num=5) { order('created_at DESC').limit(num) }

  def test_execution_items
    TestExecutionItem.where(test_execution_id: self.id).order('id')
  end



end
