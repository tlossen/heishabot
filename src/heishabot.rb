require 'rubygems'
require 'mqtt'

# connect to local mosquitto instance
MQTT::Client.connect('localhost') do |c|
  # subscribe to heishamon topics
  c.get("panasonic_heat_pump") do |topic, message|
    puts "#{topic}: #{message}"
  end
end