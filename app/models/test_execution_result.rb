# == Schema Information
#
# Table name: test_execution_results
#
#  id                :integer          not null, primary key
#  test_execution_id :integer
#  result            :text
#  duration          :decimal(, )
#  exitstatus        :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class TestExecutionResult < ActiveRecord::Base
  #include Qualified
  belongs_to :test_execution

  def quality
    self.test_execution.quality.flatten | self.test_execution.test_execution_items.collect{ |tpi| tpi.quality }.flatten
  end
  alias_method :overall_quality, :quality


  def decide_quality
    q = self.quality


  end
end
