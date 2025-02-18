require "active_support/core_ext/integer/time"
require 'colorize'

Rails.application.configure do
  config.active_storage.service = ENV['ACTIVE_STORAGE_SERVICE'].to_sym
  # Settings specified here will take precedence over those in config/application.rb.

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.solid_queue.silence_polling = true
  config.solid_queue.preserve_finished_jobs = true
  config.solid_queue.clear_finished_jobs_after = 2.days

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Log to STDOUT with the current request id as a default log tag.
  # config.log_tags = [ :request_id ]
  # config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  # config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  # config.action_mailer.default_url_options = { host: "example.com" }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true
  config.i18n.raise_on_missing_translations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

class CustomLoggerFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    if ["ERROR", "FATAL"].include? severity
      "#{severity}: #{msg}\n".light_red
    elsif severity == "DEBUG" then
      "#{severity}: #{msg}\n".light_yellow
    elsif severity == "WARN" then
      "#{severity}: #{msg}\n".light_magenta
    else
      "#{severity}: #{msg}\n".light_cyan
    end
  end
end

new_rails_logger = ActiveSupport::Logger.new(STDOUT)
new_rails_logger.formatter = CustomLoggerFormatter.new
Rails.logger = ActiveSupport::TaggedLogging.new(new_rails_logger)

new_active_record_logger = ActiveSupport::Logger.new(STDOUT)
new_active_record_logger.formatter = CustomLoggerFormatter.new
ActiveRecord::Base.logger = ActiveSupport::TaggedLogging.new(new_active_record_logger)
ActiveRecord::Base.logger.level = ENV.fetch("RAILS_LOG_LEVEL", "error").to_sym

Rack::MiniProfiler.config.authorization_mode = :allow_authorized