class TestPlan < ActiveRecord::Base
  # explicitly name join_table to prevent ar default naming
  has_and_belongs_to_many :test_items, join_table: :test_plans_test_items
  accepts_nested_attributes_for :test_items

  validates :name, :presence => true, length: {minimum: 3}
  #TODO validate base_url to be there and valid url (?)

  include Trackable
  include Sluggable
end
