class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.references :system, index: true
      t.string :group
      t.string :plugin
      t.string :ds
    end
  end
end
