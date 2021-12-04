require "mqtt/v3/client"

INFLUX_URL = "http://localhost:8086/write?db=heishamon"

# connect to local mosquitto instance
transport = MQTT::Transport::TCP.new("localhost", 8883, nil)
client = MQTT::V3::Client.new(transport)
client.connect

# subscribe to heishamon topics
client.subscribe("panasonic_heat_pump/#") do |key, payload|
  value = String.new(payload)
  puts "#{key}: #{value}"
  Process.fork do
    # publish metric to local influxdb instance
    system "curl -XPOST '#{INFLUX_URL}' --data-binary '#{key} value=#{value}'"
  end
end

# keep listening forever
while true
  sleep(10)
end
