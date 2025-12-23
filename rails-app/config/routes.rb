Rails.application.routes.draw do
  resources :people, only: [:index, :new, :create, :show, :edit, :update, :destroy]
  
  root "people#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
