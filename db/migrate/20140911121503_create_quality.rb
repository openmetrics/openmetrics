class CreateQuality < ActiveRecord::Migration
  def change
    create_table :qualities do |t|
      t.string :entity_type
      t.integer :entity_id
      t.integer :quality_criterion_id
      t.integer :test_execution_id
      t.integer :status
      t.text :message
    end
  end
end
