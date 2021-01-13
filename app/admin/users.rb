ActiveAdmin.register User do
  includes :tweets, :likes, :following

  member_action :ban, method: :put

  index do
    column :id
    column :name
    column :email
    column :pic_url
    column :user_type
    column :created_at
    column :following_user_count
    column :tweet_count
    column :retweet_count
    column :like_count

    actions defaults: true do |user|
      link_to(user.banned? ? 'Unban' : 'Ban', ban_admin_user_path(user), method: :put)
    end
  end

  form do |f|
    inputs 'Edit user details' do
      input :email
      input :name
      input :pic_url
      input :user_type, include_blank: false
      input :password
    end
    actions
  end

  permit_params :email, :name, :pic_url, :password, :user_type

  controller do
    def update
      if (params[:user][:password].blank? && params[:user][:password_confirmation].blank?)
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end

    def ban
      user = User.find(params[:id])
      user.toggle!(:banned)

      if user.save
        respond_to do |format|
          format.html { redirect_to admin_users_path, notice: "User #{user} #{user.banned? ? 'banned' : 'unbanned'}." }
        end
      end
    end
  end
  
  filter :email
  filter :name
  filter :user_type, as: :select
  filter :created_at, as: :date_range
end
