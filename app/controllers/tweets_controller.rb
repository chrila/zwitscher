class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[show update destroy retweet like]

  def format_tweet_content(content)
    content.gsub(/#\b\w+\b/) { |hashtag| "<a href=#{tweets_path}?q[content_cont]=%23#{hashtag[1..]}>#{hashtag}</a>" }
  end
  helper_method :format_tweet_content

  def index
    @q = Tweet.tweets_for_me(current_user).ransack(params[:q])
    @tweets = @q.result.order(id: :desc).page(params[:page])
  end

  def show
  end

  def create
    @tweet = Tweet.new(tweet_params)
    @tweet.user = current_user

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to root_path, notice: 'Tweet was successfully created.' }
      else
        format.html { redirect_to root_path, alert: 'Tweet could not be created.' }
      end
    end
  end

  def like
    @tweet.toggle_like(current_user)

    respond_to do |format|
      notice = "Tweet #{@tweet.liked?(current_user) ? 'liked' : 'unliked'}"
      format.js { render nothing: true, notice: notice }
      format.html { redirect_to root_path, notice: notice }
    end
  end

  def retweet
    new_tweet = @tweet.retweet(current_user)

    respond_to do |format|
      if new_tweet
        format.html { redirect_to root_path, notice: 'Retweeted!' }
      else
        format.html { redirect_to root_path, alert: 'Retweet not successful.' }
      end
    end
  end

  def update
  end

  def destroy
    @tweet.destroy

    respond_to do |format|
      notice = 'Tweet deleted.'
      format.js {render nothing: true, notice: notice }
      format.html { redirect_to root_path, notice: notice }
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:content)
  end

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end
end
