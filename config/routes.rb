Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    post '/users/:id/follow', to: 'users/registrations#follow', as: 'user_follow'
  end

  resources :tweets
  post 'tweets/:id/like', to: 'tweets#like', as: 'tweet_like'
  post 'tweets/:id/retweet', to: 'tweets#retweet', as: 'tweet_retweet'

  root 'tweets#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
