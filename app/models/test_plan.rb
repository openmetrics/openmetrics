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

class TestPlan < ActiveRecord::Base
  # explicitly name join_table to prevent ar default naming
  #has_and_belongs_to_many :test_items, join_table: :test_plans_test_items
  #accepts_nested_attributes_for :test_items

  has_many :test_plan_items, dependent: :destroy
  has_many :test_items, through: :test_plan_items
  accepts_nested_attributes_for :test_plan_items, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }

  validates :name, :presence => true, length: {minimum: 3}
  #TODO validate base_url to be there and valid url (?)

  include Trackable
  include Sluggable
end
