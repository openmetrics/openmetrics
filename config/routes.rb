Openmetrics::Application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # start at welcomepage
  root 'welcome_page#display'

  resources :activities

  # devise and user related routes
  # use custom RegistrationsController and SessionsController
  devise_for :users, :controllers => { :registrations => 'registrations', sessions: 'sessions'}
  as :user do
    get '/login' => 'devise/sessions#new'
    delete '/logout' => 'devise/sessions#destroy'
    put '/users/update_password', :to => 'registrations#update_password'
    post '/users/generate_token', :to => 'registrations#generate_token', as: :generate_user_token
    delete '/users/remove_token', :to => 'registrations#delete_token', as: :remove_user_token
  end

  # provides user_path, e.g. /users/1 and due to friendly_id /users/<username>
  get '/users/:id', :to => 'users#show', :as => :user

  # system's routes
  resources :systems
  post 'systems/scan' => 'systems#scan', as: :scan_system
  post 'systems/profile' => 'systems#profile', as: :profile_system
  resources :ip_lookups
  resources :system_lookups

  # services's routes
  resources :services
  # organize services under /service_name and use ServicesController for all
  resources :collectd_services, controller: 'services', type: 'collect_service'
  resources :dns_services, controller: 'services', type: 'dns_service'
  resources :http_services, controller: 'services', type: 'http_service'
  resources :ssh_services, controller: 'services', type: 'ssh_service'
  resources :ntp_services, controller: 'services', type: 'ntp_service'
  resources :openmetrics_services, controller: 'services', type: 'openmetrics_service'
  resources :openmetrics_agent_services, controller: 'services', type: 'openmetrics_agent_service'

  resources :collectd_plugins


  # webtest routes
  resources :webtests
  resources :test_items
  resources :test_plans
  post 'test_plans/run' => 'test_plans#run', as: :run_test_plan
  resources :test_suites
  resources :test_cases
  resources :test_scripts
  resources :test_executions
  get 'test_executions/:id/poll' => 'test_executions#poll', as: :poll_test_execution

  # project routes
  resources :projects
  post 'projects/run' => 'projects#run', as: :run_test_project

  # Enable this route for sidekiq monitoring
  # Remember to add 'sinatra' in Gemfile
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # temp admin area with sidekiq within iframe
  get 'admin' => 'welcome_page#admin'

  #search
  get '/searches/:query' => 'searches#search', :as => 'search'

  # fileuploads
  resources :uploads

  # API v1 routes
  # http://jes.al/2013/10/architecting-restful-rails-4-api/
  # http://andrewberls.com/blog/post/api-versioning-with-rails-4
  constraints do
    scope module: 'api' do
      namespace :v1 do
        resources :systems
        resources :services
      end
    end
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
