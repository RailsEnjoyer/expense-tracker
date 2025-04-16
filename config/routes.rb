Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :expenses
  resources :users, only: [:show, :edit, :update, :destroy]

  get '/signup', to: 'registrations#new', as: 'signup'
  post '/signup', to: 'registrations#create', as: 'registrations'

  root "expenses#index"
end
