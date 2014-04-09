class TestSuite < ActiveRecord::Base
  has_and_belongs_to_many :test_cases
end
