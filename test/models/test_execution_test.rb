# == Schema Information
#
# Table name: test_executions
#
#  id           :integer          not null, primary key
#  test_plan_id :integer
#  user_id      :integer
#  status       :integer
#  created_at   :datetime
#  updated_at   :datetime
#  job_id       :string(255)
#  base_url     :string(255)
#  started_at   :datetime
#  finished_at  :datetime
#

require 'test_helper'

class TestExecutionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
