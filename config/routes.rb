Rails.application.routes.draw do
  root to: 'things#new'

  resources :things
end
