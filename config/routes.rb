Rails.application.routes.draw do
  
  get '/' => "device_types#browse"
  get '/devices/search' => "devices#search"
  get 'browse' => "device_types#browse"

  resources :device_types
  resources :groups
  resources :devices
  resources :models
  resources :brands

  # Omniauth callbacks
  post '/auth/:provider/callback' => 'application#auth_callback'
  get '/auth/:provider/callback' => 'application#auth_callback'

  namespace :api, only: [ :show ], defaults: { format: :json } do
    resources :devices do
      collection do
        post 'register'
        put 'poll'
      end
    end
  end
end
