Blitzen::Application.routes.draw do
  root :to => 'home#index'

  # These are essentially static pages, so routing them through
  # HomeController to avoid having to create empty controllers for each
  get 'contact' => 'home#contact', :as => :contact
  get 'videos' => 'home#videos', :as => :videos

  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  get 'signup' => 'users#new', :as => :signup
  get 'account' => 'users#edit', :as => :account

  get 'blog/page/:page' => 'blog#page', :as => :page, :page => /\d{1,4}/
  get 'blog/posts/:id' => 'blog#show', :as => :blogpost, :id => /\d{9,20}/
  get 'blog'=> redirect('/')

  get 'shows/admin' => 'shows#admin', :as => :shows_admin
  get 'shows/archive' => 'shows#archive_index', :as => :archive_index
  get 'shows/archive/:year' => 'shows#year', :as => :show_year
  get 'shows/archive/:year/:month' => 'shows#month', :as => :show_month
  get 'shows/search' => 'shows#search'
  get 'shows/edit_setlist/:id' => 'shows#edit_setlist', :as => :edit_setlist
  get 'shows/cancel_setlist/:id' => 'shows#cancel_setlist', :as => :cancel_setlist
  get 'shows/refresh' => 'shows#refresh'

  get 'forum/page/:page' => 'topics#index'
  get 'topic/search' => 'topics#search'

  get 'users/facebook-login' => 'users#facebook_request', :as => :facebook_request
  get 'users/facebook-callback' => 'users#facebook_callback', :as => :facebook_callback
  get 'users/nuke/:id' => 'users#nuke', :as => :nuke_user

  resources :topics, :path => 'forum'
  resources :shows
  resources :songs
  resources :records
  resources :posts
  resources :users
  resource :user_session

  # redirects
  get 'tour-promo' => redirect('/shows')
  get 'tour-presale' => redirect('/shows')
  get 'stream-auth' => redirect('/')
  get 'vh3yT4zx' => redirect('/')
  get 'american-goldwing-presale' => redirect('/store')
  get 'american-goldwing-promo' => redirect('/store')
  get 'home' => redirect('/')
  get 'tree' => 'home#tree'
  get 'blitzen-trapper-massacre' => 'home#massacre'

  # legacy URLs
  get 'index.php' => redirect('/')
  get 'forum.php' => redirect('/forum')
  get 'forum/index.php' => redirect('/forum')
  get 'topic.php' => 'topics#redirect_by_id'
  get 'profile.php' => 'users#redirect_by_id'
  get 'rss.php' => redirect('/posts.atom')

  get 'topic/:id' => redirect("/forum/%{id}")
  get 'rss/topic/:id' => redirect("/forum/%{id}")
  get 'profile/:id' => redirect("/users/%{id}")

  get 'rexx.html' => redirect('/records')
  get 'tour.html' => redirect('/shows')
  get 'about.html' => redirect('/contact')
  get 'contact.html' => redirect('/contact')
  get 'list.html' => redirect('/')
  get 'photos.html' => redirect('/')
  get 'vids.html' => redirect('/videos')

  # this breaks localstorage asset urls
  # get '*not_found' => 'application#not_found'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   get 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   get 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
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
  # get ':controller(/:action(/:id(.:format)))'
end
