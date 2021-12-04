require 'rubygems'
require 'mqtt'

MOSQUITTO_HOST = "localhost"
INFLUX_URL = "http://localhost:8086/write?db=heishamon"

# connect to local mosquitto instance
MQTT::Client.connect(MOSQUITTO_HOST) do |c|
  puts "#{Time.now} connected to mosquitto on #{MOSQUITTO_HOST}"

  # subscribe to heishamon topics
  c.get("panasonic_heat_pump/#") do |topic, message|
    puts "#{Time.now} #{topic}: #{message}"
    system "curl -XPOST '#{INFLUX_URL}' --data-binary '#{topic} value=#{message}'"
  end
end