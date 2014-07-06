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
