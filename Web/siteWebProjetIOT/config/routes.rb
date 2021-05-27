Rails.application.routes.draw do
  root 'sessions#welcome'

  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#logout'
  post 'login', to: 'sessions#create'

  resources :users, only: [:index, :new, :edit, :create, :update, :destroy]

  resources :trucks
  get 'messages', to: 'sessions#messages'

  mount ActionCable.server => '/cable'
end
