class TestSuite < TestItem
  has_and_belongs_to_many :test_cases, join_table: :test_suites_test_cases
end
