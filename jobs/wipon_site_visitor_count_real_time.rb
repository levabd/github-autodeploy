require 'google/api_client'
require 'date'

# Update these to match your own apps credentials
service_account_email = 'wipon-dashing@dashing-widget-1227.iam.gserviceaccount.com' # Email of service account
key_file = '/home/bitnami/wipon_analytics/Dashing-Widget-a6da79f01f9f.p12' # File containing your private key
key_secret = 'notasecret' # Password to unlock private key
profile_id = '101701600' # Analytics profile ID.

# Get the Google API client
client = Google::APIClient.new(
  :application_name => 'wipon-dashing', 
  :application_version => '0.01'
)

visitors = []

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)

# Start the scheduler
SCHEDULER.every '10s', :first_in => 0 do

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')

  # Execute the query
  response = client.execute(:api_method => analytics.data.realtime.get, :parameters => {
    'ids' => "ga:" + profile_id,
    'metrics' => "ga:activeVisitors",
  })

  visitors << { x: Time.now.to_i, y: response.data.rows }

  # Update the dashboard
  send_event('wipon_site_visitor_count_real_time', points: visitors)
end