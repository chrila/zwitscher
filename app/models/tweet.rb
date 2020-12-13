class Tweet < ApplicationRecord
  belongs_to :user
  has_many :likes
  has_many :retweets, class_name: 'Tweet', foreign_key: :tweet_id
  belongs_to :original_tweet, class_name: 'Tweet', foreign_key: :tweet_id, optional: true

  validates :content, presence: true
end
