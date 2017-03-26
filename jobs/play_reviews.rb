#!/usr/bin/env ruby
require 'active_support'
require 'rubygems'
require 'market_bot'
require 'json'

# Find your apps package as part as Google Play url. i.e.
# Chrome's Google Play url is https://play.google.com/store/apps/details?id=com.android.chrome
# then Chrome's application package is com.android.chrome
apps_mapping = [
  'com.wipon.wipon'
]

SCHEDULER.every '60s', :first_in => 0 do |job|
  apps_mapping.each do |app_identifier|
    begin
      app = MarketBot::Play::App.new(app_identifier)
      reviews = MarketBot::Play::Reviews.new(app)
      reviews.update
      reviews.result.each_with_index do |review, index|
        if defined?(send_event)
          send_event("review" + "-" + (index+1).to_s + "-" + app_identifier, {
          	author: review[:author],
          	date: review[:date],
          	reviewTitle: review[:title],
		reviewText: review[:review],
          	rating: review[:rating],
          })
        end
      end
    rescue Exception => e
      puts "Error: #{e}"
    end
  end
end
