# == Schema Information
#
# Table name: test_items
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :text
#  format      :string(255)
#  markup      :text
#

require 'test_helper'

class TestItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
