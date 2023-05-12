require 'statsig'
require_relative 'mock_servers/flaky_log_event'

# Settings
NUM_EVENTS = 100
BATCH_SIZE = 1
LOGGER_THREAD_POOL_SIZE = 5
LOGGER_RETRY_LIMIT = 3
SLEEP_BETWEEN_EVENTS = 0.1
FULL_BACKOFF = 10**(LOGGER_RETRY_LIMIT-1) + 10*(LOGGER_RETRY_LIMIT-2) # includes max random additive
CUSTOM_BACKOFF = Proc.new {|retries_remaining| 1}
SLEEP_BEFORE_SHUTDOWN = 10

MockServer.start_server

options = StatsigOptions.new
options.api_url_base = 'http://localhost:4567/v1'
options.logging_max_buffer_size = BATCH_SIZE
options.logging_interval_seconds = 99999
options.logger_threadpool_size = LOGGER_THREAD_POOL_SIZE
options.post_logs_retry_limit = LOGGER_RETRY_LIMIT
options.post_logs_retry_backoff = CUSTOM_BACKOFF
Statsig.initialize('secret-key', options)
user = StatsigUser.new(user_id: 'kenny')

def running_threads
  Thread.list.select {|thread| thread.status == "run" && !thread.name&.index("statsig").nil? }
end
def sleeping_threads
  Thread.list.select {|thread| thread.status == "sleep" && !thread.name&.index("statsig").nil? }
end

logs = File.open("logs/test_event_loss.log", "w")
(1..NUM_EVENTS).each do
  Statsig.log_event(user, 'test_event')
  logs.write("=== Current thread usage ===\n"\
    "Running(#{running_threads.count}): \n#{running_threads.join("\n")}\n"\
    "Sleeping(#{sleeping_threads.count}): \n#{sleeping_threads.join("\n")}\n"
  )
  sleep SLEEP_BETWEEN_EVENTS
end
logs.write("Finished logging events, waiting for lagging retries...")
sleep SLEEP_BEFORE_SHUTDOWN
logs.close

Statsig.shutdown
MockServer.stop_server