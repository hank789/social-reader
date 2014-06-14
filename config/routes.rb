require 'sidekiq/web'
require 'api/api'

Gitlab::Application.routes.draw do
  #
  # Search
  #
  get 'search' => "search#show"
  get 'search/autocomplete' => "search#autocomplete", as: :search_autocomplete

  # API
  API::API.logger Rails.logger
  mount API::API => '/api'

  # Get all keys of user
  get ':username.keys' => 'profiles/keys#get_keys' , constraints: { username: /.*/ }

  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web, at: "/admin/sidekiq", as: :sidekiq
  end

  #
  # Global snippets
  #
  resources :snippets do
    member do
      get "raw"
    end
  end
  get "/s/:username" => "snippets#user_index", as: :user_snippets, constraints: { username: /.*/ }

  #
  # Public namespace
  #
  namespace :public do
    resources :services, only: [:index]
    root to: "services#index"
  end

  #
  # Attachments serving
  #
  get 'files/:type/:id/:filename' => 'files#download', constraints: { id: /\d+/, type: /[a-z]+/, filename:  /.+/ }

  #
  # Admin Area
  #
  namespace :admin do
    resources :users, constraints: { id: /[a-zA-Z.\/0-9_\-]+/ } do
      member do
        put :block
        put :unblock
      end
    end

    resources :broadcast_messages, only: [:index, :create, :destroy]
    resource :logs, only: [:show]
    resource :background_jobs, controller: 'background_jobs', only: [:show]
    get "rss_feeds/fetch_posts" => "rss_feeds#fetch_posts"
    resources :rss_feeds
    resources :services, constraints: { id: /[a-zA-Z.\/0-9_\-]+/ }, only: [:index, :show] do

    end

    root to: "dashboard#index"
  end

  #
  # Profile Area
  #
  resource :profile, only: [:show, :update] do
    member do
      get :design

      put :reset_private_token
      put :update_username
    end

    scope module: :profiles do
      resource :account, only: [:show, :update]
      resource :notifications, only: [:show, :update]
      resource :password, only: [:new, :create, :edit, :update] do
        member do
          put :reset
        end
      end
      resources :keys
      resources :emails, only: [:index, :create, :destroy]
      resource :avatar, only: [:destroy]
    end
  end

  match "/u/:username" => "users#show", as: :user, constraints: { username: /.*/ }, via: :get



  #
  # Dashboard Area
  #
  resource :dashboard, controller: "dashboard", only: [:show] do

  end
  get 'dashboard/stars' => "dashboard#stars"
  get 'dashboard/analytics' => "dashboard#analytics"
  get 'dashboard/archive' => "dashboard#archive"

  match 'events/mark_above_as_read/:id' => "events#mark_above_as_read", as: :events_mark_above_as_read, via: :put
  resources :events do
    member do
      post :favorite
      post :unfavorite
    end
  end
  #resources :projects, constraints: { id: /[^\/]+/ }, only: [:new, :create]

  devise_for :users, controllers: { omniauth_callbacks: :omniauth_callbacks, registrations: :registrations , passwords: :passwords}
  get 'services/test' => "services#test"
  get 'services/rssfeeds/:id' => "rssfeeds#add_rss_feed"
  get 'rssfeeds/rss' => "rssfeeds#rss"
  post 'rssfeeds/create_rss' => "rssfeeds#create_rss"
  post 'rssfeeds/apply_import' => "rssfeeds#apply_import"
  post 'rssfeeds/add_feed' => "rssfeeds#add_feed"
  post 'rssfeeds/delete_feed/:id' => "rssfeeds#delete_feed", as: :rssfeeds_delete_feed
  resources :services do

  end
  scope 'services' do
    resources :rssfeeds, only: [:update, :destroy] do

    end
  end
  controller :services do
    scope "/users/auth", :as => "auth" do
      get ':provider/callback' => :create
      get :failure
    end
  end
  resource :wall, only: [:show], constraints: {id: /\d+/} do
    member do
      get 'notes'
    end
  end

  resources :notes, only: [:index, :create, :destroy, :update], constraints: {id: /\d+/} do
    member do
      delete :delete_attachment
    end

    collection do
      post :preview
    end
  end
  root to: "dashboard#show"
end
