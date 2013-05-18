# coding: utf-8
require 'tweetstream'
require './geeokitv'

TweetStream.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
  config.auth_method        = :oauth
end

tv = GeeokiTV.new

#COMPORT接続後数秒はコマンドを受け付けないから接続するまで待つ
puts "wait connection"
tv.wait_connection

client = TweetStream::Client.new

client.on_timeline_status do |status|
  puts status.text

  # もしも@geeokibotが含まれるツイートが来たら電源をオン/オフする
  if status.text =~ /@geeokibot/
    puts "電源オンオフ"
    tv.power
  end
end

client.on_error do |message|
  puts "Error: #{message}"
end

client.on_reconnect do |timeout, retries|
  "Reconnecting... (#{retries})"
end

client.userstream
