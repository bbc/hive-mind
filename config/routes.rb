Rails.application.routes.draw do
  
  get '/' => "device_types#browse"
  get '/devices/search' => "devices#search"
  get '/dash/:ids' => "devices#dash"
  get 'browse' => "device_types#browse"
  get '/status' => 'application#status'

  resources :device_types
  resources :groups
  resources :devices
  resources :models
  resources :brands

  # Omniauth callbacks
  post '/auth/:provider/callback' => 'application#auth_callback'
  get '/auth/:provider/callback' => 'application#auth_callback'

  get 'api/devices/:id', to: 'devices#show', defaults: { format: :json }
  get 'api/devices', to: 'devices#index', defaults: { format: :json }

  get '/status' => 'api/status#show'

  namespace :api, only: [ ], defaults: { format: :json } do
    resources :devices do
      collection do
        post 'register'
        put 'poll'
        put 'action'
        put 'hive_queues'
        put 'screenshot'
        put 'update_state'
      end
    end
    resources :device_statistics do
      collection do
        post 'upload'
        get 'stats/:device_id/:key/:npoints' => 'device_statistics#get_stats'
      end
    end
  end
end
