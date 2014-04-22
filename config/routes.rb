Openmetrics::Application.routes.draw do
  get "test_execution/show"
  get "test_cases/new"
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # start at welcomepage
  root 'welcome_page#display'

  # devise and user related routes
  as :user do
    get "/login" => "devise/sessions#new"
    delete "/logout" => "devise/sessions#destroy"
  end
  get '/users/:id', :to => 'users#show', :as => :user  # provides user_path

  # system's routes
  resources :systems
  post 'systems/scan' => 'systems#scan', as: :scan_system
 
  # ip lookups
  resources :ip_lookups

  # services's routes
  resources :services

  # webtest routes
  resources :webtests
  resources :test_plans
  post 'test_plans/run' => 'test_plans#run', as: :run_test_plan
  resources :test_suites
  resources :test_cases

  # Enable this route for sidekiq monitoring
  # Remember to add 'sinatra' in Gemfile
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # temp admin area with sidekiq within iframe
  get 'admin' => 'welcome_page#admin'


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
