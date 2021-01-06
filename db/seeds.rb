# create test data

require 'faker'

rand(10..20).times do |i|
  u = User.create(email: Faker::Internet.unique.email, name: Faker::Name.unique.name, password: Faker::Internet.password, pic_url: "https://picsum.photos/#{1000 + i}/600")
end

(User.count * rand(10..20)).times do
  # randomly choose user
  user_id = rand(User.first.id..User.last.id)

  # choose if the user creates a new tweet or if he shall do a retweet
  if rand(1..4) == 4 && Tweet.count > 0
    tweet_id = rand(Tweet.first.id..Tweet.last.id)
    Tweet.find(tweet_id).retweet(User.find(user_id))
  else
    # randomly choose type of quote
    quote = rand(1..3)
    content = case quote
      when 1 then Faker::TvShows::MichaelScott.quote
      when 2 then Faker::TvShows::GameOfThrones.quote
      when 3 then Faker::TvShows::Simpsons.quote
    end

    Tweet.create(user_id: user_id, content: content)
  end
end

User.all.each do |u|
  Tweet.all.each do |t|
    Like.create(tweet: t, user: u) if rand(1..5) == 1
  end
end

# admin user
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?