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
    user = User.new
    user.update_attributes!(:username => 'admin',
                            :slug => 'adminuser', # admin would conflict with FriendlyId
                             :password => 'adminadmin',
                             :password_confirmation => 'adminadmin',
                             :email => 'admin@example.com')
    

    
    # load fixtures
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'test_item_types')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'test_items')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'test_plans')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'test_plan_items')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'systems')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'services')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'running_services')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'collectd_plugins')
    ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), 'running_collectd_plugins')

    # create some quality criteria for first Test Plan
    tp = TestPlan.first
    QualityCriterion.create!(entity_type: 'TestPlan', entity_id: tp.id, attr: 'duration', operator: 'lt', value: '100')
    #QualityCriterion.create!(entity_type: 'TestPlan', entity_id: tp.id, attr: 'defects', operator: 'eq', value: '0')
    #QualityCriterion.create!(entity_type: 'TestPlan', entity_id: tp.id, attr: 'fails', operator: 'eq', value: '0')
    QualityCriterion.create!(entity_type: 'TestItem', entity_id: tp.test_items.first.id, attr: 'duration', operator: 'lt', value: '100')
    QualityCriterion.create!(entity_type: 'TestItem', entity_id: tp.test_items.first.id, attr: 'exitstatus', operator: 'eq', value: '0')
    QualityCriterion.create!(entity_type: 'TestItem', entity_id: tp.test_items.first.id, attr: 'stderr', operator: 'is', value: 'empty')
    QualityCriterion.create!(entity_type: 'TestItem', entity_id: tp.test_items.first.id, attr: 'stdout', operator: 'contains', value: '/.*(foo|bar).*/i')

    # attach collectd services as running_services to base system
    # ss = Service.find all
    # ss.each do |service|
    #   rs = RunningService.new(
    #     system: system,
    #     service: service,
    #     type: service.type,
    #     description: 'test running service'
    #   )
    #   system.running_services << rs
    # end


 
    puts "#{'*'*(`tput cols`.to_i)}\nThe database has been populated!\n#{'*'*(`tput cols`.to_i)}"
    puts "Setup complete."
    puts "\nYou can login to openmetrics with user:'admin' pw:'adminadmin' now!"
  end
end
