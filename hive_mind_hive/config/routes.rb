Rails.application.routes.draw do
  resources :api, only: [], defaults: { format: :json } do
    collection do
      resources :plugin, only: []  do
        collection do
          resources :hive, controller: 'hive_mind_hive/api', only: [] do
            collection do
              put 'connect'
              put 'disconnect'
            end
          end
        end
      end
    end
  end
end
