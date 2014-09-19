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
  include Qualified
  belongs_to :test_execution
end
