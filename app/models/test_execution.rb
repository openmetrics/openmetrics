class TestExecution < ActiveRecord::Base
  belongs_to :test_plan
  # TestExecutionItem belongs to TestExecution, but we currently use method test_execution_items
  # has_many :test_execution_items
  has_one :test_execution_result

  # create result and schedule execution
  after_create :create_result
  after_commit :schedule_test_execution, on: :create

  # most recent test executions
  scope :recent, ->(num=5) { order('created_at DESC').limit(num) }

  # virtual attribute execution time in millisecond precision, calculated from started_at and finished_at
  def duration
    return nil if self.started_at.nil? or self.finished_at.nil?
    (self.finished_at - self.started_at).round(3) #milisecond precision
  end

  def test_execution_items
    TestExecutionItem.where(test_execution_id: self.id).order('id')
  end

  # execution status related methods
  def not_scheduled?
    self.job_id.nil?
  end
  def is_scheduled?
    self.status == TEST_EXECUTION_STATUS.key('scheduled')
  end

  def is_scheduled_and_not_executed?
    self.status == TEST_EXECUTION_STATUS.key('scheduled') and self.test_execution_result.exitstatus.nil?
  end

  def is_scheduled_or_prepared?
    self.status == TEST_EXECUTION_STATUS.key('scheduled') or self.status == TEST_EXECUTION_STATUS.key('prepared')
  end

  def is_prepared?
    self.status == TEST_EXECUTION_STATUS.key('prepared')
  end

  def is_finished?
    self.status == TEST_EXECUTION_STATUS.key('finished')
  end

  def is_running?
    self.test_execution_result.exitstatus.nil? and (self.is_prepared? or self.is_scheduled?) and not self.is_scheduled_and_not_executed?
  end


  # create associated TestExecutionResult for latter processing
  def create_result()
    TestExecutionResult.create!(test_execution: self)
  end

  # try to perform async, otherwise fail with meaningful status
  # use update_column here to bypass callbacks (were already within transaction here due to after_commit callback)
  def schedule_test_execution()
    begin
      update_column :status, 5 #init with 'none' state, as scheduling may fail
      update_column :job_id, TestExecutionWorker.perform_async(self.id, self.test_plan_id)
      update_column :status, TEST_EXECUTION_STATUS.key('scheduled')
      logger.info "TestPlan #{self.test_plan_id} scheduled for execution (jid: #{self.job_id})."
    rescue Exception => e
      # job scheduling failed
      logger.error "Failed to schedule TestPlan #{self.test_plan_id} due to exception #{e.message}"
    end
  end

end
