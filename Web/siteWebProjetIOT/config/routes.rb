Rails.application.routes.draw do
  root 'sessions#welcome'
  resources :users, only: [:index, :new, :edit, :create, :update, :destroy]

  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#logout'
  post 'login', to: 'sessions#create'
  get 'messages', to: 'sessions#messages'

  mount ActionCable.server => '/cable'
end
