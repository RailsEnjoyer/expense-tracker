Rails.application.routes.draw do
  get "registrations/new"
  get "registrations/create"
  get "users/new"
  get "users/create"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :expenses

  root "expenses#index"
end
