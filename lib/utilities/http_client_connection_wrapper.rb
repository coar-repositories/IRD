# frozen_string_literal: true
module Utilities
  class HttpClientConnectionWrapper
    require "faraday"
    require "faraday/follow_redirects"
    require "faraday/retry"

    attr_reader :redirect_url_chain, :connection, :new_url

    def initialize(redirect_limit = 6)
      # Callback function for FaradayMiddleware::Retry will only be called if retry is needed
      retry_options = {
        max: 2,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2
      }
      @redirect_url_chain = []
      # Callback function for FaradayMiddleware::FollowRedirects will only be called if redirected to another url
      redirects_opts = {}
      redirects_opts[:callback] = proc do |old_response, new_response|
        @redirect_url_chain << old_response.url.to_s
        @new_url = new_response.url
      end
      redirects_opts[:limit] = redirect_limit
      ssl_options = { verify: false }
      @connection = Faraday.new(ssl: ssl_options) do |faraday|
        # faraday.use FaradayMiddleware::FollowRedirects, redirects_opts
        faraday.response :follow_redirects, redirects_opts
        faraday.request :retry, retry_options
        faraday.response :raise_error # raise Faraday::Error on status code 4xx or 5xx
        faraday.options.timeout = 30
        faraday.adapter Faraday.default_adapter
      end
      @new_url = nil
    end

    def get(url)
      @new_url = url
      @connection.get(url)
    end
  end
end