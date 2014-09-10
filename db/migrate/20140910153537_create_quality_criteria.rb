class CreateQualityCriteria < ActiveRecord::Migration
  def change
    create_table :quality_criteria do |t|
      t.integer :test_plan_id
      t.string :attr
      t.string :operator
      t.string :value
    end
  end
end
