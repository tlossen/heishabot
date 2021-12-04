require "mqtt/v3/client"

INFLUX_URL = "http://localhost:8086/write?db=heishamon"

transport = MQTT::Transport::TCP.new("localhost", 8883, nil)
client = MQTT::V3::Client.new(transport)
client.connect
client.subscribe("panasonic_heat_pump/main/#") do |key, payload| #
  send(key, String.new(payload))
end

def send(key, value)
  puts "#{key}: #{value}"
  Process.fork do
    system "curl -i -XPOST '#{INFLUX_URL}' --data-binary '#{key} value=#{value}'"
  end
end

while true
  sleep(10)
end
