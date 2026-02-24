require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Blitzen
  class Application < Rails::Application
    config.load_defaults 7.0

    config.time_zone = 'Pacific Time (US & Canada)'
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :password_confirmation]

    config.active_support.to_time_preserves_timezone = :zone
    config.active_storage.variant_processor = :mini_magick

    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false
  end
end
