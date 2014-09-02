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

class TestItem < ActiveRecord::Base
  attr_readonly(:type)
  has_and_belongs_to_many :test_plans, :join_table => :test_plans_test_items
  belongs_to :test_item_type
  before_create :set_type

  def set_type()
      test_item_type = TestItemType.find_by_model_name(self.class)
  end
end
