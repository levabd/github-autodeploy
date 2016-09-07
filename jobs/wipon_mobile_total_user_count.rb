require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = 'wipon-dashing@dashing-widget-1227.iam.gserviceaccount.com' # Email of service account
key_file = '/home/bitnami/wipon_analytics/Dashing-Widget-a6da79f01f9f.p12' # File containing your private key
key_secret = 'notasecret' # Password to unlock private key
profileID = '101737256' # Analytics profile ID.

# Get the Google API client
client = Google::APIClient.new(:application_name => 'wipon-dashing', 
  :application_version => '0.01')

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Start the scheduler
SCHEDULER.every '6h', :first_in => 0 do

  data = { 
    :users => {
      androidUsersCount: 0,
      iosUsersCount: 0
    }
  }

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Start and end dates
  startDate = DateTime.new(2015,03,01,8,37,48,"-06:00").strftime("%Y-%m-%d") # date of Wipon very first release
  endDate = DateTime.now.strftime("%Y-%m-%d")  # now

  # Execute the query
  # Note the trailing to_i - See: https://github.com/Shopify/dashing/issues/33

  data[:users][:androidUsersCount] = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + profileID, 
    'start-date' => startDate,
    'end-date' => endDate,
    'dimensions' => "ga:operatingSystem",
    'metrics' => "ga:users",
    # 'sort' => "ga:month" 
  }).data.rows[1][1].to_i

  data[:users][:iosUsersCount] = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + profileID, 
    'start-date' => startDate,
    'end-date' => endDate,
    'dimensions' => "ga:operatingSystem",
    'metrics' => "ga:users",
    # 'sort' => "ga:month" 
  }).data.rows[3][1].to_i + 
  client.execute(:api_method => analytics.data.ga.get, :parameters => { 
    'ids' => "ga:" + profileID, 
    'start-date' => startDate,
    'end-date' => endDate,
    'dimensions' => "ga:operatingSystem",
    'metrics' => "ga:users",
    # 'sort' => "ga:month" 
  }).data.rows[6][1].to_i


  # Update the dashboard
  send_event('wipon_mobile_total_user_count',   data)
end