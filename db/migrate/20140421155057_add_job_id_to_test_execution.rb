class AddJobIdToTestExecution < ActiveRecord::Migration
  def change
    add_column :test_executions, :job_id, :string
  end
end
