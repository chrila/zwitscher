class Tweet < ApplicationRecord
  belongs_to :user
  has_many :likes
  has_many :retweets, class_name: 'Tweet', foreign_key: :tweet_id
  belongs_to :original_tweet, class_name: 'Tweet', foreign_key: :tweet_id, optional: true

  validates :content, presence: true

  def liked?(user)
    likes.where(user: user).size.positive?
  end

  def like(user)
    Like.create(user: user, tweet: self)
  end

  def unlike(user)
    Like.where(user: user).destroy_all
  end

  def toggle_like(user)
    if liked?(user)
      unlike(user)
    else
      like(user)
    end
  end

  def like_count
    likes ? likes.length : 0
  end

  def retweet_count
    retweets ? retweets.length : 0
  end
end
