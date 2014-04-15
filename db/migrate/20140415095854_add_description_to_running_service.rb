class AddDescriptionToRunningService < ActiveRecord::Migration
  def change
       change_table(:running_services) do |t|
         t.column :description, :text
       end
  end
end
