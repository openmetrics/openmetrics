require 'active_record/fixtures'

namespace :openmetrics do
  
  
   # Checks and ensures task is not run in production.
  task :ensure_development_environment => :environment do
    if Rails.env.production?
      raise "\nI'm sorry, I can't do that.\n(You're asking me to drop your production database.)"
    end
  end
  
  # Custom install for developement environment
  desc "Setup"
  task :setup => [:ensure_development_environment, "db:migrate", "db:seed", "openmetrics:populate"]
 
  # Custom reset for developement environment
  desc "Reset"
  task :reset => [:ensure_development_environment, "db:drop", "db:create", "db:migrate", "db:seed", "openmetrics:populate"]
 
  # Populates development data
  desc "Populate the database with development data."
  task :populate => :environment do
  	puts "#{'*'*(`tput cols`.to_i)}\nChecking Environment... The database will be cleared of all content before populating.\n"
    # Removes content before populating with data to avoid duplication
    Rake::Task['db:reset'].invoke
    
    # create admin user
    user = User.new()
    user.update_attributes!(:username => 'admin',
                             :password => 'adminadmin',
                             :password_confirmation => 'adminadmin',
                             :email => "admin@example.com")
    
    # create base system (localhost)
    system = System.new()
    system.update_attributes!(:name => 'localhost',
                              :fqdn => Socket.gethostbyname(Socket.gethostname).first)
    
    # load some fixtures
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'test_items')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'services')
 
    puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
    puts "Setup complete."
    puts "\nYou can login to openmetrics with user:'admin' pw:'adminadmin' now!"
  end
end
