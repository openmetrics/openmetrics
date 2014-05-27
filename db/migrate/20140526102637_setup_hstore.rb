class SetupHstore < ActiveRecord::Migration
  def self.up
    #execute "CREATE EXTENSION IF NOT EXISTS hstore" 
    enable_extension "hstore"
  end
  
  def self.down
    #execute "DROP EXTENSION IF EXISTS hstore"
    disable_extension "hstore"
  end
end
