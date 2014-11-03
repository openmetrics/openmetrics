# enables hstore extension, see http://yousefourabi.com/blog/2014/03/rails-postgresql/ and https://gist.github.com/tehpeh/3735174
namespace :db do
  namespace :enable do
    desc "enable hstore extension"
    task :hstore => [:environment, :load_config] do

      # check postgresql version to be >= 9.x
      sql = "SELECT version();"
      # returns sth like "PostgreSQL 9.3.5 on x86_64-unknown-linux-gnu, compiled by gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3, 64-bit"
      result_array = ActiveRecord::Base.connection.execute(sql)
      version = result_array.values.first.first.scan(/PostgreSQL (.+) on/).first.first
      version_number = version.to_i

      if version_number < 9
        abort "PostgreSQL server version < 9.x! Aborting."
      else
        # check if user has superuser rights (needed to activate extension)
        dbconfig = Rails.configuration.database_configuration
        db_user = dbconfig[Rails.env]['username']
        db_name = dbconfig[Rails.env]['database']
        sql = "SELECT * FROM pg_roles where rolname = '#{db_user}' and rolsuper = true"
        records_array = ActiveRecord::Base.connection.execute(sql)
        is_superuser = records_array.values.size == 1 ? true : false
        if is_superuser
          puts "Activating PostgreSQL hstore extension"
          ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS hstore;')
        else
          sql = "select * from pg_available_extensions where name = 'hstore'"
          records_array = ActiveRecord::Base.connection.execute(sql)
          hstore_available = records_array.values.size == 1 ? true : false
          if hstore_available
            ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS hstore;')
          else
            abort "Failed to enable PostgreSQL hstore extension for database '#{db_name}' - only superuser can do so!"
          end
        end
      end

    end
  end
 
  #Rake::Task['db:schema:load'].enhance ['db:enable:hstore']
  Rake::Task['db:migrate'].enhance ['db:enable:hstore']
end
