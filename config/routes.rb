ActionController::Routing::Routes.draw do |map|

  map.connect '/fb/:action', :controller => 'facebook'

  map.resources :votes
  map.resources :answers
  map.resources :questions, :collection => { :unanswered => :get }

  map.resources :questions do |question|
    question.resources :tags do |tag|
      tag.resources :answers
    end
    question.resources :answers
  end

  map.resources :roles

  map.resources :concepts, :as => "wiki"
  map.resources :concepts do |concept|
    concept.resources :revisions
  end

  map.resources :friendships

  map.resources :users, :collection => {:link_user_accounts => :get} do |user|
    user.resources :activities
    user.resources :tags do |tag|
      tag.resources :posts
    end
    user.resources :posts do |post|
      post.resources :comments do |comment|
        comment.resources :comments, :as => "replies"
      end
    end
  end

  map.resource :user_session

  map.resources :tags

  map.create_country "create_country", :controller => "concepts", :action => "create_country"
  map.create_organization "create_organization/:country_id", :controller => "concepts", :action => "create_organization"
  map.register "register", :controller => "users", :action => "new"
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"
  map.blog 'user/:user/blog', :controller => "posts", :action => "index"
  map.post 'user/:user/blog/:id', :controller => 'posts', :action => 'show', :id => ''
  map.user_profile 'user/:user', :controller => "users", :action => "show"
  map.questions_tag 'questions/tag/:tag', :controller => "questions", :action => "index"
  map.zeitgeist "zeitgeist/:tag", :controller => "zeitgeist", :action => "index"
  map.list 'list/:category', :controller => 'concepts', :action => 'list'
  map.page 'wiki/show/:id', :controller => 'concepts', :action => 'show'

  map.root :controller => "site" 

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
