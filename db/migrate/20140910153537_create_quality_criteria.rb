class CreateQualityCriteria < ActiveRecord::Migration
  def change
    create_table :quality_criteria do |t|
      t.integer :entity_id
      t.string :entity_type
      t.string :attr
      t.string :operator
      t.string :value
      t.string :unit
    end
  end
end
