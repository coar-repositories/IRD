%w[
    ALLOW_TEST_USER_ACCOUNTS_WITHOUT_VERIFICATION
    APP_VERSION
    DEFAULT_PLATFORM
    IRD_DB_CONNECTION_POOL
    IRD_DB_HOST
    IRD_DB_PORT
    IRD_DB_USERNAME
    JOBS_CONCURRENCY
    JOBS_MAX_THREADS
    OPENSEARCH_BATCH_SIZE
    OPENSEARCH_URL
    PREVENT_PUBLIC_ACCESS_TO_DATA
    RAILS_ENV
    RAILS_FORCE_SSL
    RAILS_LOG_LEVEL
    RAILS_MASTER_KEY
    RAILS_MAX_THREADS
    RAILS_MIN_THREADS
    RAILS_SERVER_BASE_URL
    RP_FOR_ARCHIVED_RECORDS
    RP_FOR_LIVE_RECORDS
    SMTP_ADDRESS
    SMTP_DOMAIN
    SMTP_PASSWORD
    SMTP_PORT
    SMTP_USERNAME
    WEB_CONCURRENCY
    WEBSITE_THUMBNAIL_GENERATION_CONCURRENCY
  ].each do |env_var|
  # if !ENV.has_key?(env_var) || ENV[env_var].blank?
  unless ENV.has_key?(env_var)
    raise <<~EOL
      Missing environment variable: #{env_var}
      This ENV variable is listed in the initializer ('config/initializers/01_ensure_environment.rb') as a required variable.
    EOL
  end
end
