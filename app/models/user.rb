class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include DeviseTokenAuth::Concerns::User

  enum user_type: [ :personal, :corporate ]

  has_many :tweets, dependent: :delete_all
  has_many :likes, dependent: :delete_all
  has_many :following, class_name: 'Following', foreign_key: 'user_id', dependent: :delete_all
  has_many :followed_by, class_name: 'Following', foreign_key: 'following_user'

  after_commit :follow_self, on: :create
  
  def to_s
    name
  end

  def follow_self
    follow(self)
  end

  def follow(other_user)
    Following.create(user: self, following_user: other_user) unless following?(other_user)
  end

  def unfollow(other_user)
    following.where(following_user: other_user).destroy_all if following?(other_user)
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
    User.where.not(id: following.map(&:following_user_id)).limit(4)
  end

  def following_user_count
    following_users.size
  end

  def tweet_count
    tweets.size
  end

  def retweet_count
    tweets.retweets.size
  end

  def like_count
    likes.size
  end

  def active_for_authentication? 
    !banned? 
  end
end
