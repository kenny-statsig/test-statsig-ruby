require 'sinatra/base'

$log_event_counter = 0
$dcs_counter = 0
$seen_events = Hash.new

# Lives on http://localhost:4567
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
    File.write("logs/log_event_#{Process.pid}.log",
               "Finished: #{Time.now.utc.iso8601}\n"\
               "Success Count: #{$log_event_counter}\n"\
               "Attempts: #{JSON.pretty_generate($seen_events)}")
    return 500
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
