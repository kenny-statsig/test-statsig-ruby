require 'statsig'
require_relative 'mock_servers/delayed_log_event'

# Settings
NUM_EVENTS = 100
BATCH_SIZE = 1
LOGGER_THREAD_POOL_SIZE = 3
LOGGER_RETRY_LIMIT = 3
SLEEP_BETWEEN_EVENTS = 0.1
CUSTOM_BACKOFF = Proc.new {|retries_remaining| (LOGGER_RETRY_LIMIT - retries_remaining) * 2}
SLEEP_BEFORE_SHUTDOWN = 15

MockServer.start_server

options = StatsigOptions.new
options.api_url_base = 'http://localhost:4567/v1'
options.logging_max_buffer_size = BATCH_SIZE
options.logging_interval_seconds = 99999
options.logger_threadpool_size = LOGGER_THREAD_POOL_SIZE
options.post_logs_retry_limit = LOGGER_RETRY_LIMIT
options.post_logs_retry_backoff = CUSTOM_BACKOFF
options.disable_diagnostics_logging = true
Statsig.initialize('secret-key', options)
user = StatsigUser.new(user_id: 'kenny')
logging_pool = Statsig.instance_variable_get("@shared_instance").instance_variable_get("@logger").instance_variable_get("@logging_pool")

def running_threads
  Thread.list.select {|thread| thread.status == "run" && !thread.name&.index("statsig").nil? }
end
def sleeping_threads
  Thread.list.select {|thread| thread.status == "sleep" && !thread.name&.index("statsig").nil? }
end

logs = File.open("logs/test_event_loss.log", "w")
(1..NUM_EVENTS).each do |i|
  Statsig.log_event(user, "event_#{i}")
  logs.write("[#{Time.now.utc.iso8601}] === Current thread usage ===\n"\
    "Running(#{running_threads.count}): \n#{running_threads.join("\n")}\n"\
    "Sleeping(#{sleeping_threads.count}): \n#{sleeping_threads.join("\n")}\n"\
    "Logging pool queue usage: #{logging_pool.queue_length}/#{logging_pool.max_queue}\n"
  )
  sleep SLEEP_BETWEEN_EVENTS
end
logs.write("[#{Time.now.utc.iso8601}] Finished logging events, waiting for lagging retries...\n")
sleep SLEEP_BEFORE_SHUTDOWN

Statsig.shutdown
logs.write("[#{Time.now.utc.iso8601}] Shutting down Statsig\n")
MockServer.stop_server
logs.write("[#{Time.now.utc.iso8601}] Shutting down Server\n")
logs.close