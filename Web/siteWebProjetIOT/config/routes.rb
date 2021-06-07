Rails.application.routes.draw do
  root 'sessions#welcome'

  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#logout'
  post 'login', to: 'sessions#create'

  resources :users, only: [:index, :new, :edit, :create, :update, :destroy]

  resources :trucks do #index, show, new, edit, create, update, destroy
    get "truckInfoImages/:id", action: :truckInfoImages, as: 'images'
  end

  get 'api/addTruckInfo', to: 'trucks#addTruckInfo'
  post 'api/addTruckInfo', to: 'trucks#addTruckInfo'

  get 'testApi', to: 'sessions#testApi'

  mount ActionCable.server => '/cable'
end
