class TestExecutionItem < ActiveRecord::Base
  include Pollable
  belongs_to :test_item
  belongs_to :test_execution

  # virtual attribute execution time in millisecond precision, calculated from started_at and finished_at
  def duration
    return nil if self.started_at.nil? or self.finished_at.nil?
    (self.finished_at - self.started_at).round(3)
  end

end
