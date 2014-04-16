class TestCase < ActiveRecord::Base
  has_and_belongs_to_many :test_suites, join_table: :test_suites_test_cases
end
