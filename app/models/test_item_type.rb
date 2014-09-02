# == Schema Information
#
# Table name: test_item_types
#
#  id          :integer          not null, primary key
#  model_name  :string(255)      not null
#  name        :string(255)      not null
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class TestItemType < ActiveRecord::Base
  has_many :test_items
end
