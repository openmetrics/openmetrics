class TestExecution < ActiveRecord::Base
  belongs_to :test_plan

  after_create :schedule_test_execution

  # try to perform async, otherwise fail
  def schedule_test_execution()
    begin
      self.job_id = TestExecutionWorker.perform_async(self.test_plan_id)
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
