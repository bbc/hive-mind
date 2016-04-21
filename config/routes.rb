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
  namespace :api, only: [ ], defaults: { format: :json } do
    resources :devices do
      collection do
        post 'register'
        put 'poll'
        put 'action'
        put 'hive_queues'
      end
    end
  end
end
