require 'sinatra/base'

$log_event_counter = 0
$dcs_counter = 0
$seen_events = Hash.new

# Lives on http://localhost:4567
# Random chance to either succeed (200) or fail (500)
class MockApp < Sinatra::Base
  post '/v1/download_config_specs' do
    $dcs_counter += 1
    200
  end
  post '/v1/log_event' do
    data = JSON.parse request.body.read
    data["events"].each do |event|
      name = event["eventName"]
      if $seen_events.key?(name)
        $seen_events[name] += 1
      else
        $seen_events[name] = 1
      end
    end
    if rand(0..1) == 1
      status = 200
      $log_event_counter += 1
    else
      status = 500
    end
    File.write("logs/log_event_#{Process.pid}.log",
               "Finished: #{Time.now.utc.iso8601}\n"\
               "Success Count: #{$log_event_counter}\n"\
               "Attempts: #{JSON.pretty_generate($seen_events)}")
    return status
  end
end

class MockServer
  def self.start_server
    @thread = Thread.new do
      MockApp.run!
    end
    sleep 1
  end

  def self.stop_server
    MockApp.stop!
    @thread.kill
  end
end
