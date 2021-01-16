class Api::ApiController < ActionController::API
  before_action :authenticate_user!, only: [:create]

  include DeviseTokenAuth::Concerns::SetUserByToken

  def news
    render json: tweet_hash_array(Tweet.news)
  end

  def between
    render json: tweet_hash_array(Tweet.between(params[:date_from], params[:date_to]))
  end

  def create
    @tweet = Tweet.new(tweet_params)
    @tweet.user = current_user
    
    if @tweet.save
      render json: { status: 'success' }
    else
      render json: { status: 'error' }
    end
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

  def tweet_params
    params.require(:tweet).permit(:content)
  end

end
