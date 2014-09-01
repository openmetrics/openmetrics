class CreateSystemVariables < ActiveRecord::Migration
  def change
    create_table :system_variables do |t|
      t.string :name
      t.string :value
      t.integer :system_id
    end
  end
end
