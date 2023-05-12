require 'sinatra/base'

$log_event_counter = 0
$dcs_counter = 0

# Lives on http://localhost:4567
class MockApp < Sinatra::Base
  post '/v1/download_config_specs' do
    $dcs_counter += 1
    200
  end
  post '/v1/log_event' do
    File.write("logs/log_event_#{Process.pid}.log", $log_event_counter)
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
