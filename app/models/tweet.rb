class Tweet < ApplicationRecord
  belongs_to :user
  has_many :likes
  has_many :retweets, class_name: 'Tweet', foreign_key: :tweet_id
  belongs_to :original_tweet, class_name: 'Tweet', foreign_key: :tweet_id, optional: true

  validates :content, presence: true

  paginates_per 50

  def retweet(user)
    Tweet.create(original_tweet: self, content: 'Retweet', user: user)
  end

  def liked?(user)
    likes.where(user: user).size.positive?
  end

  def like(user)
    Like.create(user: user, tweet: self)
  end

  def unlike(user)
    likes.where(user: user).destroy_all
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
    retweets ? retweets.size : 0
  end

  scope :tweets_for_me, -> (user) { where(user: user.following_users) if user.present? }
  scope :retweets, -> { where.not(original_tweet: nil) }
end
