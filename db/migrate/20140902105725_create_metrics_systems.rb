class CreateMetricsSystems < ActiveRecord::Migration
  def change
    create_table :metrics_systems do |t|
      t.references :system, index: true
      t.references :metric, index: true
    end
  end
end
