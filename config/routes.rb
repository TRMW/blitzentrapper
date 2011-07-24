ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'home'
  
  # user stuff
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.account 'account', :controller => 'users', :action => 'edit'
  
  # oauth2 stuff
  map.oauth_authorize 'oauth/start', :controller => 'oauth', :action => 'start'
	map.oauth_callback 'oauth/callback', :controller => 'oauth', :action => 'callback'
  
  # blog stuff
  map.blog 'blog', :controller => 'blog', :action => 'index'
  map.page 'blog/page/:page', :controller => 'blog', :action => 'page', :page => /\d{1,4}/
  map.blogpost 'blog/posts/:id', :controller => 'blog', :action => 'show', :id => /\d{9,20}/
  
  # show archive stuff
  map.show_archive 'shows/admin', :controller => 'shows', :action => 'admin'
  map.archive_index 'shows/archive', :controller => 'shows', :action => 'year', :year => Date.today.strftime('%Y')
  map.show_year 'shows/archive/:year', :controller => 'shows', :action => 'year'
  map.show_month 'shows/archive/:year/:month', :controller => 'shows', :action => 'month'
  map.connect 'shows/search', :controller => 'shows', :action => 'search'
  map.connect 'shows/edit_setlist', :controller => 'shows', :action => 'edit_setlist'
  map.connect 'shows/cancel_setlist', :controller => 'shows', :action => 'cancel_setlist'
  
  # forum stuff
  map.connect 'forum.php', :controller => 'topics', :action => 'redirect_home'
  map.connect 'index.php', :controller => 'topics', :action => 'redirect_home'
  map.connect 'forum/index.php', :controller => 'topics', :action => 'redirect_home'
  map.connect 'forum/page/:page', :controller => 'topics', :action => 'index'
  map.connect 'topic/search', :controller => 'topics', :action => 'search'
  map.resources :topics, :as => 'forum'
  
  # resources
  map.resources :shows
  map.resources :songs
  map.resources :records
  map.resources :posts
  map.resources :users
  map.resource :user_session
  map.resources :products, :as => 'merch', :except => :show
  
  map.connect '/tree', :controller => 'home', :action => 'tree'
  map.connect '/blitzen-trapper-massacre', :controller => 'home', :action => 'massacre'
  
  # Redirect old pages
  map.connect 'topic/:id', :controller => 'topics', :action => 'redirect'
  map.connect 'topic.php', :controller => 'topics', :action => 'redirect_by_id'
  map.connect 'rss/topic/:id', :controller => 'topics', :action => 'redirect'
  map.connect 'rss.php', :controller => 'posts', :action => 'redirect_feed'
  map.connect 'profile/:id', :controller => 'users', :action => 'redirect'
  map.connect 'profile.php', :controller => 'users', :action => 'redirect_by_id'
  map.connect 'rexx.html', :controller => 'records', :action => 'redirect'
  map.connect 'tour.html', :controller => 'shows', :action => 'redirect'
  map.connect 'about.html', :controller => 'home', :action => 'redirect'
  map.connect 'contact.html', :controller => 'home', :action => 'redirect'
  map.connect 'list.html', :controller => 'home', :action => 'redirect'
  map.connect 'photos.html', :controller => 'home', :action => 'redirect'
  map.connect 'vids.html', :controller => 'home', :action => 'redirect'

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
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
