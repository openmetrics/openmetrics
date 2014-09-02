# == Schema Information
#
# Table name: webtests
#
#  id          :integer          not null, primary key
#  description :text
#  base_url    :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'test_helper'

class WebtestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
