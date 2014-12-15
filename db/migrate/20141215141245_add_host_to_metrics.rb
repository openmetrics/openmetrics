class AddHostToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :host, :string
  end
end
