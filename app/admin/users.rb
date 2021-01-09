ActiveAdmin.register User do
  includes :tweets, :likes, :following

  index do
    column :id
    column :name
    column :email
    column :pic_url
    column :created_at
    column :following_user_count
    column :tweet_count
    column :retweet_count
    column :like_count

    actions
  end

  form do |f|
    inputs 'Edit user details' do
      input :email
      input :name
      input :pic_url
      input :password
    end
    actions
  end

  permit_params :email, :name, :pic_url, :password

  controller do
    def update
      if (params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end
  
  filter :email
  filter :name
  filter :created_at, as: :date_range
end
