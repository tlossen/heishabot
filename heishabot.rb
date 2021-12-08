#!/usr/bin/env ruby
require 'rubygems'
require 'mqtt'
require 'work_queue'

MOSQUITTO_HOST = "localhost"
INFLUX_URL = "http://localhost:8086/write?db=heishamon"

def log(message)
  STDOUT.puts "#{Time.now} #{message}"
  STDOUT.flush
end

# background job queue with multiple workers
queue = WorkQueue.new(5, nil)

# keep reconnecting
while true do
  begin
  # connect to local mosquitto instance
    MQTT::Client.connect(MOSQUITTO_HOST) do |mqtt|
      log "connected to mosquitto on #{MOSQUITTO_HOST}"

      # subscribe to all heishamon topics
      mqtt.get("panasonic_heat_pump/main/#") do |topic, message|

        # store each message in influxdb
        queue.enqueue_b do 
          log "#{topic}: #{message}"
          system "curl -XPOST '#{INFLUX_URL}' --data-binary '#{topic} value=#{message}'"
        end
      end
    end
  rescue Errno::ECONNREFUSED
    log "connecting to mosquitto on #{MOSQUITTO_HOST} ..."
    sleep(5)
  end
end