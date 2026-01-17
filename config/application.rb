require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module JewelryApp
  class Application < Rails::Application
    # `config.load_defaults` was added in Rails 5.1+. Guard it so this
    # skeleton remains compatible with Rails 5.0.x (railties 5.0.7.2).
    if config.respond_to?(:load_defaults)
      config.load_defaults 5.0
    end

  # Use local India time so Date/Time helpers return expected local dates (IST)
  config.time_zone = 'Asia/Kolkata'
  end
end
