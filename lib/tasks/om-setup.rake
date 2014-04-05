# 
# To change this template, choose Tools | Templates
# and open the template in the editor.



namespace :openmetrics do
  
  desc "Creates the AdminUser and the Roles"
  task(:setup => :environment) do
      
        puts "\nCreating admin user"
        @user = User.new()
        @user.update_attributes!(:username => 'admin',
                             :password => 'adminadmin',
                             :password_confirmation => 'adminadmin',
                             :email => "admin@example.com")

        puts "Setup complete."
        puts "\nYou can login to openmetrics with user:'admin' pw:'adminadmin' now!"
      
  end #task
end
