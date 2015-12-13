Rails.application.routes.draw do
  root to: 'home#index'

  resources :things do
    member do
      post :create_comment
      get  :next_comments
    end
  end

  resources :users

  get  "sessions/sign_up_form"
  post "sessions/sign_up"
  get  "sessions/sign_out"

  get  "sessions/sign_in_form"
  post "sessions/sign_in"

  get  "sessions/wake_up_form/:id", controller: :sessions, action: :wake_up_form
  post "sessions/wake_up/:id", controller: :sessions, action: :wake_up, as: :session_wake_up

  namespace :api do
    namespace :v1 do
      resources :things do#, to: API::V1::Thing::Controller
        resources :comments
      end
      resources :users
      resources :comments
    end
  end
end
