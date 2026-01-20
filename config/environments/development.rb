Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Reload code between requests. Good for development.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
end
