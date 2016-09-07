require 'uptimerobot'

apiKey = 'u296689-1f0058e1e883e842ab5e71d9'

SCHEDULER.every '5m', :first_in => 0 do |job|
  client = UptimeRobot::Client.new(apiKey: apiKey)

  raw_monitors = client.getMonitors['monitors']['monitor']

  monitors = raw_monitors.map { |monitor| 
    { 
      friendlyname: monitor['friendlyname'], 
      value: if monitor['status'] == '0' then 'Paused' elsif monitor['status'] == '2' then 'Up' elsif monitor['status'] == '9' then 'Down' else 'Unknown' end,
      status: 'S' << monitor['status']
    }
  }

  send_event('uptimerobot', { monitors: monitors } )
end
