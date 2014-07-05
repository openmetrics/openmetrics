module Executable
  extend ActiveSupport::Concern

  included do
    # schedule execution and create result
    after_create :create_result
    after_commit :schedule_execution, on: :create

    # most recent test executions
    scope :recent, ->(num=5) { order('created_at DESC').limit(num) }

  end

  # virtual attribute execution time in millisecond precision, calculated from started_at and finished_at
  def duration
    return nil if self.started_at.nil? or self.finished_at.nil?
    (self.finished_at - self.started_at).round(3) #milisecond precision
  end


  # execution status related methods
  def not_scheduled?
    self.job_id.nil?
  end
  def is_scheduled?
    self.status == EXECUTION_STATUS.key('scheduled')
  end

  def is_scheduled_and_not_executed?
    self.status == EXECUTION_STATUS.key('scheduled') and self.test_execution_result.exitstatus.nil?
  end

  def is_scheduled_or_prepared?
    self.status == EXECUTION_STATUS.key('scheduled') or self.status == EXECUTION_STATUS.key('prepared')
  end

  def is_prepared?
    self.status == EXECUTION_STATUS.key('prepared')
  end

  def is_finished?
    self.status == EXECUTION_STATUS.key('finished')
  end

  def is_running?
    self.test_execution_result.exitstatus.nil? and (self.is_prepared? or self.is_scheduled?) and not self.is_scheduled_and_not_executed?
  end


end