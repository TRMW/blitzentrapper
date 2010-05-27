ActionController::Routing::Routes.draw do |map|
  # map.root :controller => 'home'
  map.resources :shows
  map.resources :songs
  map.resources :records
  map.resources :posts
  map.connect 'forum/page/:page', :controller => 'topics', :action => 'index'
  map.resources :topics, :as => 'forum'
  
  map.connect '/blog/page/:id/', :controller => 'blog', :action => 'page', :id => /\d{2}/
  map.blogpost '/post/:id/:slug', :controller => 'blog', :action => 'show', :id => /\d{9}/

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  
  map.resources :user_sessions
  map.resources :users
    
  # Redirect old pages
  map.connect '/topic/:id/', :controller => 'home', :action => 'redirect' # :controller => 'topics', :action => 'redirect'
  map.connect '/rexx.html', :controller => 'home', :action => 'redirect' # :controller => 'records', :action => 'redirect'
  map.connect '/tour.html', :controller => 'home', :action => 'redirect' # :controller => 'shows', :action => 'redirect'
  map.connect '/about.html', :controller => 'home', :action => 'redirect'
  map.connect '/contact.html', :controller => 'home', :action => 'redirect'
  map.connect '/list.html', :controller => 'home', :action => 'redirect'
  map.connect '/photos.html', :controller => 'home', :action => 'redirect'
  map.connect '/vids.html', :controller => 'home', :action => 'redirect'

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
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
