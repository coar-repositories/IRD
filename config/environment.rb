# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do

  # config.active_storage.service = ENV['ACTIVE_STORAGE_SERVICE'].to_sym # This is set in the environment files - it *doesn't work* if set here!!!!
  config.force_ssl = ENV['RAILS_FORCE_SSL'].downcase == 'true'
  config.assume_ssl = ENV['RAILS_FORCE_SSL'].downcase == 'true'


end

Rails.application.config.after_initialize do
  Rails.application.config.ird.repoid_schemes[:ird][:http_prefix] = "#{Rails.application.routes.url_helpers.systems_url}/"
end

