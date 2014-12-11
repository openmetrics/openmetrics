class AddErrorToSystemLookupResults < ActiveRecord::Migration
  def change
    add_column :system_lookup_results, :error, :text
  end
end
