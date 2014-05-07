class AddStartedAtAndFinishedAtToTestExecution < ActiveRecord::Migration
  def change
    add_column :test_executions, :started_at, :datetime
    add_column :test_executions, :finished_at, :datetime
  end
end
