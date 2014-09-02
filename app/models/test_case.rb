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

class TestCase < TestItem
  # explicitly name join_table to prevent ar default naming
  has_and_belongs_to_many :test_suites, join_table: :test_suites_test_cases

  include Trackable
end
