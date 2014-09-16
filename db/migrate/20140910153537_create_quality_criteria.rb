class CreateQualityCriteria < ActiveRecord::Migration
  def change
    create_table :quality_criteria do |t|
      t.integer :qualifiable_id
      t.string :qualifiable_type
      t.string :attr
      t.string :operator
      t.string :value
      t.string :unit
    end
  end
end
