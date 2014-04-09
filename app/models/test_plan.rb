class TestPlan < ActiveRecord::Base
  has_many :test_items, -> { :type => ['TestCase', 'TestSuite'] }
end
