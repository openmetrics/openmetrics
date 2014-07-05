class TestCase < TestItem
  # explicitly name join_table to prevent ar default naming
  has_and_belongs_to_many :test_suites, join_table: :test_suites_test_cases

  include Trackable
end
