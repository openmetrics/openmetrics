class RenameIpLookupJobKeyToJobId < ActiveRecord::Migration
  def change
    rename_column :ip_lookups, :job_key, :job_id
  end
end
