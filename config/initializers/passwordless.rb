Passwordless.configure do |config|
  config.expires_at = lambda { 1.month.from_now } # How long until a signed in session expires.
  config.timeout_at = lambda { 30.minutes.from_now } # How long until a token/magic link times out.
  config.restrict_token_reuse = false # Can a token/link be used multiple times?
  config.redirect_back_after_sign_in = false # When enabled the user will be redirected to their previous page, or a page specified by the `destination_path` query parameter, if available.
  config.success_redirect_path = '/dashboard' # After a user successfully signs in
end