# frozen_string_literal: true
require "faraday"
require "faraday/follow_redirects"
require "faraday/retry"
require "nokogiri"

module OaiPmh
  class OaiPmhMetadataFormatsService < ApplicationService

    def call(system_id)
      begin
        @system = System.includes(:network_checks, :repoids, :media, :annotations, :users).find(system_id)
        new_url = @system.oai_base_url
        new_url_with_verb = Addressable::URI.parse(new_url)
        params = new_url_with_verb.query_values
        if params
          params.delete("verb")
        else
          params = {}
        end
        params["verb"] = "ListMetadataFormats"
        new_url_with_verb.query_values = params
        Rails.logger.debug("Running OAI-PMH Check Formats on #{new_url_with_verb}")
        # Callback function for FaradayMiddleware::Retry will only be called if retry is needed
        retry_options = {
          max: 2,
          interval: 0.05,
          interval_randomness: 0.5,
          backoff_factor: 2
        }
        # Callback function for FaradayMiddleware::FollowRedirects will only be called if redirected to another url
        redirects_opts = {}
        redirects_opts[:callback] = proc do |old_response, new_response|
          Rails.logger.debug "Redirected from #{old_response.url} to #{new_response.url}"
          new_url_with_verb = new_response.url
        end
        conn = Faraday.new do |faraday|
          faraday.response :follow_redirects, redirects_opts
          faraday.options.timeout = 10
          faraday.adapter Faraday.default_adapter
          faraday.request :retry, retry_options
          faraday.response :raise_error
        end
        response = conn.get(new_url_with_verb)
        doc = Nokogiri::XML(response.body)
        doc.remove_namespaces!

        @system.formats = {}
        doc.xpath("//metadataFormat").each do |format|
          @system.formats[format.at_xpath("metadataPrefix").text] = format.at_xpath("metadataNamespace").text
        end
      rescue StandardError => e
        Rails.logger.warn "CheckOaiPmhFormatsJob: #{e.message}"
      end
      success @system
    end
  end
end