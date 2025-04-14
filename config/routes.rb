Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :expenses

  root "expenses#index"
end
