Blitzen::Application.routes.draw do

  root :to => 'home#index'
  
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'authenticate' => 'user_sessions#create', :as => :authenticate, :via => :post
  
  match 'signup' => 'users#new', :as => :signup
  match 'connect' => 'users#update', :as => :connect, :via => :post
  match 'account' => 'users#edit', :as => :account
  match 'reset' => 'users#detonate'
  
  match 'blog' => 'blog#index', :as => :blog
  match 'blog/page/:page' => 'blog#page', :as => :page, :page => /\d{1,4}/
  match 'blog/posts/:id' => 'blog#show', :as => :blogpost, :id => /\d{9,20}/
  
  match 'shows/admin' => 'shows#admin', :as => :show_archive
  match 'shows/archive' => 'shows#year', :as => :archive_index, :year => '2011'
  match 'shows/archive/:year' => 'shows#year', :as => :show_year
  match 'shows/archive/:year/:month' => 'shows#month', :as => :show_month
  match 'shows/search' => 'shows#search'
  match 'shows/edit_setlist' => 'shows#edit_setlist'
  match 'shows/cancel_setlist' => 'shows#cancel_setlist'
  
  match 'forum.php' => 'topics#redirect_home'
  match 'index.php' => 'topics#redirect_home'
  match 'forum/index.php' => 'topics#redirect_home'
  match 'forum/page/:page' => 'topics#index'
  match 'topic/search' => 'topics#search'
  
  resources :topics, :path => 'forum'
  resources :shows
  resources :songs
  resources :records
  resources :posts
  resources :users
  resource :user_session
  resources :products, :except => :show, :path => 'merch'
 
  match '/tree' => 'home#tree'
  match '/blitzen-trapper-massacre' => 'home#massacre'
  match 'topic/:id' => 'topics#redirect'
  match 'topic.php' => 'topics#redirect_by_id'
  match 'rss/topic/:id' => 'topics#redirect'
  match 'rss.php' => 'posts#redirect_feed'
  match 'profile/:id' => 'users#redirect'
  match 'profile.php' => 'users#redirect_by_id'
  match 'rexx.html' => 'records#redirect'
  match 'tour.html' => 'shows#redirect'
  match 'about.html' => 'home#redirect'
  match 'contact.html' => 'home#redirect'
  match 'list.html' => 'home#redirect'
  match 'photos.html' => 'home#redirect'
  match 'vids.html' => 'home#redirect'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
