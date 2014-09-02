class AddNameAndRrdFileToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :name, :string
    add_column :metrics, :rrd_file, :string
  end
end
