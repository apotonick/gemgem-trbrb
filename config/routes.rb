Rails.application.routes.draw do
  root to: 'home#index'

  resources :things do
    resources :comments, only: [:create]
  end
end
