Rails.application.routes.draw do
  root to: 'home#index'

  resources :things do
    resources :comments

    # member do
    #   post :create_comment
    # end
  end

end
