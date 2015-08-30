Blitzen::Application.routes.draw do
  root :to => 'home#index'

  # These are essentially static pages, so routing them through
  # HomeController to avoid having to create empty controllers for each
  match 'contact' => 'home#contact', :as => :contact
  match 'videos' => 'home#videos', :as => :videos

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'signup' => 'users#new', :as => :signup
  match 'account' => 'users#edit', :as => :account

  match 'blog/page/:page' => 'blog#page', :as => :page, :page => /\d{1,4}/
  match 'blog/posts/:id' => 'blog#show', :as => :blogpost, :id => /\d{9,20}/
  match 'blog'=> redirect('/')

  match 'shows/admin' => 'shows#admin', :as => :shows_admin
  match 'shows/archive' => 'shows#archive_index', :as => :archive_index
  match 'shows/archive/:year' => 'shows#year', :as => :show_year
  match 'shows/archive/:year/:month' => 'shows#month', :as => :show_month
  match 'shows/search' => 'shows#search'
  match 'shows/edit_setlist/:id' => 'shows#edit_setlist', :as => :edit_setlist
  match 'shows/cancel_setlist/:id' => 'shows#cancel_setlist', :as => :cancel_setlist
  match 'shows/refresh' => 'shows#refresh'

  match 'forum/page/:page' => 'topics#index'
  match 'topic/search' => 'topics#search'

  match 'users/facebook-login' => 'users#facebook_request', :as => :facebook_request
  match 'users/facebook-callback' => 'users#facebook_callback', :as => :facebook_callback

  resources :topics, :path => 'forum'
  resources :shows
  resources :songs
  resources :records
  resources :posts
  resources :users
  resource :user_session

  match 'store' => redirect('/store/new')
  match 'merch' => redirect('/store/new')
  match 'store/:id/:slug' => 'products#show', :as => :item, :id => /\d{1,6}/
  match 'store/search' => 'products#search', :as => :store_search
  match 'store/:category' => 'products#category', :as => :store_category
  match 'export' => 'products#export'

  # redirects
  match 'tour-promo' => redirect('/shows')
  match 'tour-presale' => redirect('/shows')
  match 'stream-auth' => 'home#stream_auth'
  match 'vh3yT4zx' => 'home#vh3yT4zx'
  match 'american-goldwing-presale' => redirect('/store')
  match 'american-goldwing-promo' => redirect('/store')
  match 'home' => redirect('/')
  match 'tree' => 'home#tree'
  match 'blitzen-trapper-massacre' => 'home#massacre'

  # legacy URLs
  match 'index.php' => redirect('/')
  match 'forum.php' => redirect('/forum')
  match 'forum/index.php' => redirect('/forum')
  match 'topic.php' => 'topics#redirect_by_id'
  match 'profile.php' => 'users#redirect_by_id'
  match 'rss.php' => redirect('/posts.atom')

  match 'topic/:id' => redirect("/forum/%{id}")
  match 'rss/topic/:id' => redirect("/forum/%{id}")
  match 'profile/:id' => redirect("/users/%{id}")

  match 'rexx.html' => redirect('/records')
  match 'tour.html' => redirect('/shows')
  match 'about.html' => redirect('/contact')
  match 'contact.html' => redirect('/contact')
  match 'list.html' => redirect('/')
  match 'photos.html' => redirect('/')
  match 'vids.html' => redirect('/videos')

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
