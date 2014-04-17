class TestPlan < ActiveRecord::Base
  has_many :test_items
  accepts_nested_attributes_for :test_items

  validates :name, :presence => true, length: {minimum: 3}
end
