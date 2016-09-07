#!/usr/bin/env ruby
require 'net/http'
require 'openssl'
require 'nokogiri'

# Average+Average Voting on an Android App
#
# This job will track the average vote score and number of votes on an app
# that is registered in the google play market by scraping the google play
# market website.
#
# There are two variables send to the dashboard:
# `google_play_voters_total` containing the number of people voted
# `google_play_average_rating` float value with the average votes

# Config
# ------
appPageUrl = 'https://play.google.com/store/apps/details?id=com.wipon.wipon'

SCHEDULER.every '24h', :first_in => 0 do
  puts "fetching App Store Rating for App: " + appPageUrl
  # prepare request
  http = Net::HTTP.new("play.google.com", Net::HTTP.https_default_port())
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # disable ssl certificate check

  # scrape detail page of appPageUrl
  response = http.request( Net::HTTP::Get.new(appPageUrl) )

  if response.code != "200"
    puts "google play store website communication (status-code: #{response.code})\n#{response.body}"
  else
    data = { 
      :app => {
        averageRating: 0.0,
        votersCount: 0}, 
    }
    
    
    doc = Nokogiri::HTML::Document.parse(response.body)
    average_rating = doc.css('div.score').map(&:text)
    print "#{average_rating[0]}\n"
    # <span class="rating-count">24 Ratings</span>
    voters_count = doc.css('span.reviews-num').map(&:text)
    print "#{voters_count[0]}\n"

    #last versions average rating 
    if ( average_rating[0] )
      data[:app][:averageRating] = average_rating[0]
    else 
      puts 'ERROR::RegEx for rating didn\'t match anything'
    end

    # all and last versions voters count 
    if ( voters_count[0] )
      data[:app][:votersCount] = voters_count[0]
    else 
      puts 'ERROR::RegEx for voters count didn\'t match anything'
    end

    send_event('andorid_review_mobile', data)
  end
end