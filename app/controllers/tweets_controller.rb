class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all.limit(50)
  end

  def show
    @tweet = Tweet.find(params[:id])
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
    @tweet = Tweet.find(params[:id])
    @tweet.toggle_like(current_user)

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Tweet #{@tweet.liked?(current_user) ? 'liked' : 'unliked'}" }
    end
  end

  def update
  end

  def destroy
  end

  private

  def tweet_params
    params.require(:tweet).permit(:content)
  end
end
