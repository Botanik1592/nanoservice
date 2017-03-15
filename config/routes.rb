Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users
  root to: "home#index"

  namespace :api do
    namespace :v1 do
      resources :messages, only: [:create]
    end
  end
end
