class Api::ApiController < ActionController::API

  include DeviseTokenAuth::Concerns::SetUserByToken

  def news
    render json: tweet_hash_array(Tweet.news)
  end

  def between
    render json: tweet_hash_array(Tweet.between(params[:date_from], params[:date_to]))
  end

  private

  def tweet_hash_array(tweets)
    tweets_arr = []
    tweets.each do |t|
      tweet = { 
        id: t.id,
        content: t.content,
        user_id: t.user_id,
        like_count: t.like_count,
        retweets_count: t.retweet_count,
        retweeted_from: t.tweet_id
      }
      tweets_arr.push(tweet)
    end
    tweets_arr
  end

end
