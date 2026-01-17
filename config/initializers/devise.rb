Devise.setup do |config|
  # Configure the e-mail address which will be shown in Devise::Mailer
  config.mailer_sender = Rails.application.secrets.respond_to?(:[] ) ? (Rails.application.secrets[:mailer_sender] || 'please-change-me@example.com') : 'please-change-me@example.com'

  # Use ActiveRecord ORM
  require 'devise/orm/active_record'

  # Use the application's secret_key_base if available (recommended)
  if Rails.application.respond_to?(:secret_key_base) && Rails.application.secret_key_base.present?
    config.secret_key = Rails.application.secret_key_base
  end

  # Other Devise config defaults are acceptable for development/test here.
end
