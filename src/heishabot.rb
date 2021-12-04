require 'rubygems'
require 'mqtt'

INFLUX_URL = "http://localhost:8086/write?db=heishamon"

# connect to local mosquitto instance
MQTT::Client.connect('localhost') do |c|
  # subscribe to heishamon topics
  c.get("panasonic_heat_pump/#") do |topic, message|
    puts "#{topic}: #{message}"
    system "curl -XPOST '#{INFLUX_URL}' --data-binary '#{key} value=#{message}'"
  end
end