require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ird
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.mission_control.jobs.http_basic_auth_enabled = false

    config.generators do |g|
      # g.orm :active_record, primary_key_type: :string
      # g.test_framework :mini_test, spec: true #deliberatley disabled
    end



    # Configuration for the application, engines, and railties goes here.
    config.ird = config_for(:ird)

    if ENV['RAILS_SERVER_PORT'].present?
      routes.default_url_options = { host: ENV['RAILS_SERVER_BASE_URL'], port: ENV['RAILS_SERVER_PORT'] }
      config.action_mailer.default_url_options = { host: ENV['RAILS_SERVER_BASE_URL'], port: ENV['RAILS_SERVER_PORT'] }
    else
      routes.default_url_options = { host: ENV['RAILS_SERVER_BASE_URL'] }
      config.action_mailer.default_url_options = { host: ENV['RAILS_SERVER_BASE_URL'] }
    end

    config.action_mailer.smtp_settings = {
      address: ENV['SMTP_ADDRESS'],
      port: ENV['SMTP_PORT'].to_i,
      domain: ENV['SMTP_DOMAIN'],
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD']
    }

    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
