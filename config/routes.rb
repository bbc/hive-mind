Rails.application.routes.draw do
  resources :groups
  resources :devices do
    collection do
      post 'register'
    end
  end
  resources :models
  resources :brands
end
