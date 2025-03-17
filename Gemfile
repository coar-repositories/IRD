source "https://rubygems.org"

gem "dotenv-rails"
gem "fileutils"
gem "translate_enum"
gem "haml-rails"
# gem 'html2haml' #temporarily
gem "colorize"
gem "pundit", "~> 2.4"
gem "pagy", "~> 9.3" # omit patch digit
gem "public_suffix"
gem "thor", "~> 1.3", ">= 1.3.2"
gem "csv"
gem "addressable"
gem "kramdown"
gem "passwordless"
gem "searchkick"
gem "opensearch-ruby"
gem "mission_control-jobs"
gem "chunky_png"
gem "faraday", "~> 2.12.2"
gem "faraday-follow_redirects"
gem "faraday-retry"
gem "aws-sdk-s3"
gem "nokogiri"
gem "selenium-webdriver", "~> 4.28"
gem "acts-as-taggable-on"
gem "chartkick"
gem "bcrypt"
gem "active_snapshot"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
gem "sqlite3", ">= 2.4"
gem "pg", ">= 0.18", "< 2.0"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue", "~> 1.1.4"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
# gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"
# gem "stackprof"

group :development, :test do
  gem "rspec-rails", "~> 7.1.0"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "i18n-tasks", "~> 1.0.14"
  gem "easy_translate"
end

group :test do
  gem "rails-controller-testing"
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  # gem "selenium-webdriver" #already listed above
  gem "simplecov"
end
