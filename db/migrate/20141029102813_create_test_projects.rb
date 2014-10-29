class CreateTestProjects < ActiveRecord::Migration
  def change
    create_table :test_projects do |t|
      t.integer :test_plan_id
      t.integer :project_id
    end
  end
end
