Rails.application.routes.draw do
  root to: 'home#index'

  resources :things do
    resources :comments
  end
end
