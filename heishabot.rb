#!/usr/bin/env ruby
require 'rubygems'
require 'mqtt'

MOSQUITTO_HOST = "localhost"
INFLUX_URL = "http://localhost:8086/write?db=heishamon"

# wait for startup of mosquitto & influxdb
#sleep(45)

# connect to local mosquitto instance
MQTT::Client.connect(MOSQUITTO_HOST) do |mqtt|
  puts "#{Time.now} connected to mosquitto on #{MOSQUITTO_HOST}"

  # subscribe to all heishamon topics
  mqtt.get("panasonic_heat_pump/#") do |topic, message|
    puts "#{Time.now} #{topic}: #{message}"
    # store each message in influxdb
    system "curl -XPOST '#{INFLUX_URL}' --data-binary '#{topic} value=#{message}'"
  end
end