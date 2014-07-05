class TestExecution < ActiveRecord::Base
  belongs_to :test_plan
  # TestExecutionItem belongs to TestExecution, but we currently use method test_execution_items
  # has_many :test_execution_items
  has_one :test_execution_result


  # try to perform async, otherwise fail with meaningful status
  # use update_column here to bypass callbacks (were already within transaction here due to after_commit callback)
  include Executable
  def schedule_execution()
    begin
      update_column :status, 5 #init with 'none' state, as scheduling may fail
      update_column :job_id, TestExecutionWorker.perform_async(self.id, self.test_plan_id)
      update_column :status, EXECUTION_STATUS.key('scheduled')
      logger.info "TestPlan #{self.test_plan_id} scheduled for execution (jid: #{self.job_id})."
    rescue Exception => e
      # job scheduling failed
      logger.error "Failed to schedule TestPlan #{self.test_plan_id} due to exception #{e.message}"
    end
  end
  # create associated TestExecutionResult for latter processing
  def create_result()
    TestExecutionResult.create!(test_execution: self)
  end

  # most recent test executions
  scope :recent, ->(num=5) { order('created_at DESC').limit(num) }

  def test_execution_items
    TestExecutionItem.where(test_execution_id: self.id).order('id')
  end



end
