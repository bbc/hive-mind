Rails.application.routes.draw do
  
  get '/' => "device_types#browse"
  get 'browse' => "device_types#browse"

  resources :device_types
  resources :groups
  resources :devices do
    collection do
      post 'register'
    end
  end
  resources :models
  resources :brands

  # Omniauth callbacks
  post '/auth/:provider/callback' => 'application#auth_callback'
  get '/auth/:provider/callback' => 'application#auth_callback'
end
