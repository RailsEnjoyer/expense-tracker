Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :expenses
  resources :users, only: [:show, :edit, :update, :destroy]

  get '/signup', to: 'registrations#new', as: 'signup'
  post '/signup', to: 'registrations#create', as: 'registrations'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :logout

  root "expenses#index"
end
