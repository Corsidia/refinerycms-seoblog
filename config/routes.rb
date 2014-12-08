Refinery::Core::Engine.routes.draw do
  namespace :blog, :path => Refinery::Blog.page_url do
    root :to => "posts#index"

    get 'categories/:slug', :to => 'categories#show', :as => 'category'
    get ':category_slug/:slug', :to => 'posts#show', :as => 'post'
    get 'feed.rss', :to => 'posts#index', :as => 'rss_feed', :defaults => {:format => "rss"}
    get 'archive/:year(/:month)', :to => 'posts#archive', :as => 'archive_posts'
    get 'tagged/:tag_id(/:tag_name)' => 'posts#tagged', :as => 'tagged_posts'
  end

  namespace :blog, :path => '' do
    namespace :admin, :path => Refinery::Core.backend_route do
      scope :path => Refinery::Blog.page_url do
        root :to => "posts#index"

        resources :posts do
          collection do
            get :tags
          end
        end

        resources :categories

        resources :settings do
          collection do
            get :notification_recipients
            post :notification_recipients

            get :moderation
            get :teasers
          end
        end
      end
    end
  end
end
