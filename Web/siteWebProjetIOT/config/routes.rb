Rails.application.routes.draw do
  resources :users, only: [:index, :new, :edit, :create, :update, :destroy]

  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#logout'
  post 'login', to: 'sessions#create'
  get 'welcome', to: 'sessions#welcome'

  get 'authorized', to: 'sessions#page_requires_login'
  get 'admin_authorized', to: 'sessions#page_requires_admin'
end
