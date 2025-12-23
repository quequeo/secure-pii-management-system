Rails.application.routes.draw do
  resources :people, only: [:index, :new, :create, :show]
  
  root "people#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
