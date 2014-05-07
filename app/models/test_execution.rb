class TestExecution < ActiveRecord::Base
  belongs_to :test_plan
  # TestExecutionItem belongs to TestExecution, but we currently use method test_execution_items
  # has_many :test_execution_items
  has_one :test_execution_result

  # schedule execution directly after create
  after_create :schedule_test_execution

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

  # try to perform async, otherwise fail
  def schedule_test_execution()
    begin
      self.job_id = TestExecutionWorker.perform_async(self.id, self.test_plan_id)
      if self.save
        logger.info 'TestExecution scheduled successfully.'
      else
        logger.warn 'TestExecution failed to save.'
      end
    rescue
      logger.error 'Failed to schedule job TestExecution'
    end
  end

end
