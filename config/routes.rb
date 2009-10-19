ActionController::Routing::Routes.draw do |map|
#  map.resources :user_profiles, :as => "profile"

  map.resources :jurisdictions, :devices, :documents, :folders

  map.resources :role_requests, :controller => "role_requests"
  map.resources :organization_requests, :controller => "organization_requests"
  map.resources :role_assignments, :controller => "admin/role_assignments"
  map.resources :organization_assignments, :controller => "admin/organization_assignments"
  map.resources :admin_pending_requests, :controller => "admin/pending_requests"
  map.resources :admin_role_requests, :member => [:approve, :deny], :controller => "admin/role_requests"
  map.resources :admin_organization_requests, :member => [:approve, :deny], :controller => "admin/organization_requests"
  #map.approve_admin_organization "/admin_organizations/:id/approve", :controller => "admin/organizations", :action => "approve"
  #map.deny_admin_organization    "/admin_organizations/:id/deny",    :controller => "admin/organizations", :action => "deny"
  map.resources :admin_users, :controller => "admin/users"

  map.resources :users do |user|
    user.resource :profile, :as => "profile", :controller => "user_profiles"
    user.resources :devices
    user.confirmation "/confirm/:token", :controller => "users", :action => "confirm"
  end
  map.resources :alerts, :member => {:acknowledge => [:get, :put]}
  map.email_acknowledge_alert "alerts/:id/emailack", :controller => "alerts", :action => "acknowledge", :email => "1"
  map.token_acknowledge_alert "alerts/:id/acknowledge/:token", :controller => "alerts", :action => "token_acknowledge"
  map.upload "alerts/index/upload", :controller => "alerts", :action => "upload", :method => [:get, :post]
  map.playback "alerts/new/playback.wav", :controller => "alerts", :action => "playback", :method => [:get]
  map.resources :roles
  map.resources :organizations do |organization|
    organization.confirmation "/confirmation/:token", :controller => 'organizations', :action => 'confirmation'
  end
  map.resources :roll_calls
  map.resources :admin_groups, :controller => "admin/groups"
  
  map.resource :search
  map.dashboard "/dashboard", :controller => "dashboard", :action => "index"
  map.root :controller => "dashboard", :action => "index"
  map.about "/about", :controller => "dashboard", :action => "about"
  map.faqs "/faqs", :controller => "dashboard", :action => "faqs"
  map.hud "/han", :controller => "dashboard", :action => "hud"

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/auto_complete_for_phin_person_display_name', :action => "auto_complete_for_phin_person_display_name", :format => "json"
  #map.connect ':controller/auto_complete_for_phin_person_first_name', :action => 'auto_complete_for_phin_person_first_name', :format => 'json'
  #map.connect ':controller/auto_complete_for_phin_person_last_name', :action => "auto_complete_for_phin_person_last_name", :format => "json"
  # map.auto_complete ':controller/:action', :requirements => { :action => /auto_complete_for_\S+/ }, :conditions => { :method => :get }

  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
