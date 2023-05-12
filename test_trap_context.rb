require 'statsig'

LOG = Logger.new(STDOUT)

def setup_signals(signals)
  Thread.main[:pending_signals] = []

  signals.each { |signal|
      trap signal do
          Thread.main[:pending_signals] << signal
          Statsig.shutdown
      end
  }
end

def handle_signals
  while signal = Thread.main[:pending_signals].shift
      LOG.info "Signal #{signal} received"
      # Statsig.shutdown // where it should be
  end
end

setup_signals([:SIGINT])
Statsig.initialize('secret-key')
while true
  sleep 1
  handle_signals()
end
