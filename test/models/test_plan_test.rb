# == Schema Information
#
# Table name: test_plans
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  base_url    :string(255)
#  slug        :string(255)
#

require 'test_helper'

class TestPlanTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
