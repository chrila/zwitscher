class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tweets
  has_many :likes
  has_many :following, class_name: 'Following', foreign_key: 'user_id'
  has_many :followed_by, class_name: 'Following', foreign_key: 'following_user'

  def to_s
    name
  end

  def follow(other_user)
    Following.create(user: self, following_user: other_user)
  end

  def unfollow(other_user)
    following.where(following_user: other_user).destroy_all
  end

  def following?(other_user)
    following.where(following_user: other_user).size.positive?
  end

  def toggle_follow(other_user)
    if following?(other_user)
      unfollow(other_user)
    else
      follow(other_user)
    end
  end

  def followed_by_users
    followed_by.map(&:user)
  end

  alias followers followed_by_users

  def following_users
    following.map(&:following_user)
  end

  def users_to_follow
    u = User.where.not(id: following.map(&:following_user_id))
    u = u.where.not(id: self.id)
    u.limit(8)
  end
end
