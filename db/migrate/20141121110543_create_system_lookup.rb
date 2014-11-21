class CreateSystemLookup < ActiveRecord::Migration
  def change
    create_table :system_lookups do |t|
      t.integer :system_id
      t.string :job_id
      t.integer :user_id
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :status
      t.timestamps
    end
  end
end
