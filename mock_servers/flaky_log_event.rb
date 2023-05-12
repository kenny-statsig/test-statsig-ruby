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
    if rand(0..1) == 1
      status = 200
      $log_event_counter += 1
    else
      status = 500
    end
    File.write("logs/log_event_#{Process.pid}.log", $log_event_counter)
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
