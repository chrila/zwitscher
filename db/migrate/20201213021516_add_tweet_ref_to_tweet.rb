class AddTweetRefToTweet < ActiveRecord::Migration[6.0]
  def change
    add_reference :tweets, :tweet, null: true, foreign_key: true
  end
end
