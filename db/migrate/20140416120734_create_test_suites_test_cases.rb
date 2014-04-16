class CreateTestSuitesTestCases < ActiveRecord::Migration
  def change
    create_table :test_suites_test_cases, id: false do |t|
      t.belongs_to :test_suite
      t.belongs_to :test_case
    end
  end
end
