class ApiController < ActionController::API

  def news
    tweets = []
    Tweet.news.each do |t|
      tweet = { 
        id: t.id,
        content: t.content,
        user_id: t.user_id,
        like_count: t.like_count,
        retweets_count: t.retweet_count,
        retweeted_from: t.tweet_id
      }
      tweets.push(tweet)
    end

    render json: tweets
  end

end
