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
  
  get 'api/news'
  get 'api/:date_from/:date_to', to: 'api#between'
end
