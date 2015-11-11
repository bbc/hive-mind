Rails.application.routes.draw do
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
end
