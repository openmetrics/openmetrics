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

require 'test_helper'

class TestExecutionResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
