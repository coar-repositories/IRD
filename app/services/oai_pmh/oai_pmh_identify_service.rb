# frozen_string_literal: true
require "faraday"
require "faraday/follow_redirects"
require "faraday/retry"
require "addressable/uri"
require "nokogiri"

module OaiPmh
  class OaiPmhIdentifyService < ApplicationService


    def call(system_id, redirect_limit = 6)
      begin
        @system = System.includes(:network_checks, :repoids, :media, :annotations, :users).find(system_id)
        new_url = @system.oai_base_url
        if new_url == nil || new_url.blank?
          if @system.metadata["unconfirmed_oai_pmh_url_base_url"].blank? && @system.platform && @system.platform.oai_support
            oai_pmh_url_suffix = @system.platform.oai_suffix unless @system.platform.blank?
            unless oai_pmh_url_suffix.blank?
              unconfirmed_oai_pmh_url_base_url = (Utilities::UrlUtility.get_url_without_trailing_slash(@system.url) + oai_pmh_url_suffix)
              unconfirmed_oai_pmh_url_base_url = Utilities::UrlUtility.get_url_with_parent_folder_redirect_removed(unconfirmed_oai_pmh_url_base_url)
              @system.metadata["unconfirmed_oai_pmh_url_base_url"] = unconfirmed_oai_pmh_url_base_url
            end
          end
          new_url = @system.metadata["unconfirmed_oai_pmh_url_base_url"]
        end
        if new_url == nil || new_url.empty?
          @system.write_network_check(:oai_pmh_identify, false, "Missing OAI-PMH Base URL", 0)
          if @system.platform&.oai_support
            @system.oai_status = :not_enabled
          else
            @system.oai_status = :unsupported
          end
          return system # return early if no OAI-PMH base URL
        end
        new_url_with_verb = Addressable::URI.parse(new_url)
        params = new_url_with_verb.query_values
        if params
          params.delete("verb")
        else
          params = {}
        end
        params["verb"] = "Identify"
        new_url_with_verb.query_values = params
        Rails.logger.debug("Running OAI-PMH Identify on #{new_url_with_verb}")
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
          new_url = new_response.url
          Rails.logger.debug "Redirected from #{old_response.url} to #{new_response.url}"
        end
        redirects_opts[:limit] = redirect_limit
        ssl_options = { verify: false }
        conn = Faraday.new(ssl: ssl_options) do |faraday|
          # faraday.use FaradayMiddleware::FollowRedirects, redirects_opts
          faraday.response :follow_redirects, redirects_opts
          faraday.request :retry, retry_options
          faraday.response :raise_error # raise Faraday::Error on status code 4xx or 5xx
          faraday.options.timeout = 30
          faraday.adapter Faraday.default_adapter
        end
        response = conn.get(new_url_with_verb)
        if new_url != @system.oai_base_url
          @system.oai_base_url = new_url.to_s
          Rails.logger.debug "OAI-PMH Base updated from #{@system.oai_base_url} to #{new_url}"
        end
        @system.write_network_check(:oai_pmh_identify, true, "", response.status)
        @system.oai_status = :online
        @system.metadata.except!("unconfirmed_oai_pmh_url_base_url") # if @system.metadata["unconfirmed_oai_pmh_url_base_url"]
        parse_metadata(response)

      rescue Faraday::ResourceNotFound => e # 404
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_base_url = nil
        if @system.metadata["unconfirmed_oai_pmh_url_base_url"].blank?
          @system.oai_status = :unsupported
        else
          @system.oai_status = :not_enabled
        end
      rescue Faraday::ForbiddenError => e # 403
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_status = :unknown
      rescue Faraday::FollowRedirects::RedirectLimitReached => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_base_url = nil
        @system.oai_status = :offline
      rescue Faraday::ClientError => e # 4xx
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_status = :unknown
      rescue Faraday::TimeoutError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :offline
      rescue Faraday::NilStatusError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :unknown
      rescue Faraday::ServerError => e # 5xx
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, e.response[:status])
        @system.oai_status = :offline
      rescue Faraday::SSLError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :offline
      rescue Faraday::ConnectionFailed => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_base_url = nil
        if @system.metadata["unconfirmed_oai_pmh_url_base_url"].blank?
          @system.oai_status = :unsupported
        else
          @system.oai_status = :not_enabled
        end
      rescue Faraday::Error, StandardError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :unknown
      end
      success @system
    end

    private

    def parse_metadata(response)
      doc = Nokogiri::XML(response.body)
      doc.remove_namespaces!
      # puts doc.to_xml
      @system.metadata["oai_repo_name"] = doc.at_xpath("//repositoryName").text
      @system.metadata["oai_contact"] = doc.at_xpath("//adminEmail").text if doc.at_xpath("//adminEmail")
      doc.xpath("//description").each do |desc|
        repo_id = desc.at_xpath("//repositoryIdentifier")
        if repo_id
          @system.metadata["oai_id"] = ("oai:" + repo_id.text)
          break
        end
      end
      unless @system.metadata.empty?
        if @system.metadata["oai_id"]
          @system.add_repo_id(:OAI, @system.metadata["oai_id"])
        end
        if !@system.contact && @system.metadata["oai_contact"]
          @system.contact = @system.metadata["oai_contact"]
        end
        if !@system.description && @system.metadata["description"]
          @system.description = @system.metadata["description"]
        end
      end
    end
  end
end