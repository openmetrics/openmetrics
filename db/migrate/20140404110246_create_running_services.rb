class CreateRunningServices < ActiveRecord::Migration
  def change
    create_table :running_services do |t|

      t.timestamps
    end
  end
end
