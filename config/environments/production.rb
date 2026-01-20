Rails.application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot for performance in production
  config.eager_load = true

  # Full error reports should be disabled and errors logged instead
  config.consider_all_requests_local = false

  # Use default logging formatter so that PID and timestamp are included
  config.log_level = :info
end
