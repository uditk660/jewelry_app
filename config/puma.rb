# Puma configuration file suitable for deployment.
# Uses ENV overrides so processes/threads/workers can be tuned per-host.

# Number of Puma workers (processes). For clustered mode, set via WEB_CONCURRENCY.
workers Integer(ENV.fetch('WEB_CONCURRENCY', 2))

# Min and Max threads per worker. Tune via RAILS_MAX_THREADS.
threads_count = Integer(ENV.fetch('RAILS_MAX_THREADS', 5))
threads threads_count, threads_count

# Preload the application before forking worker processes for faster worker spawn
# and to save memory with Copy-On-Write friendly Ruby implementations.
preload_app!

rackup DefaultRackup

# Default to PORT or 3000 if not provided
port ENV.fetch('PORT', 3000)

# Allow binding to a unix socket if provided via BIND_SOCKET env var, e.g. unix:///path/to/sock
if ENV['BIND_SOCKET']
  bind ENV['BIND_SOCKET']
end

environment ENV.fetch('RAILS_ENV', 'production')

# PID / state files
pidfile ENV.fetch('PIDFILE', 'tmp/pids/puma.pid')
state_path ENV.fetch('PUMA_STATE', 'tmp/pids/puma.state')

# Logging
stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Worker boot hook: reconnect ActiveRecord (and other connections) after fork
on_worker_boot do
  # ActiveRecord
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.disconnect!
    ActiveRecord::Base.establish_connection
  end

  # If you use Redis or other clients that need explicit reconnect, add here.
end

# Graceful shutdown timeout (seconds)
worker_timeout Integer(ENV.fetch('PUMA_WORKER_TIMEOUT', 60))

# Optional: phased restart when using `pumactl phased-restart` for zero-downtime deploys
# Uncomment below if you use phased restarts and want to drain listeners on fork.
# before_fork do
#   # sleep 1
# end
