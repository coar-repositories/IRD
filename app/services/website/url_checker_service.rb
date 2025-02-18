# frozen_string_literal: true
require "faraday"
require "faraday/follow_redirects"
require "faraday/retry"
require "nokogiri"

module Website
  class UrlCheckerService < ApplicationService

    def call(system_id, parse_metadata_flag, redirect_limit = 6)
      begin
        @system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
        new_url = @system.url
        # Callback function for FaradayMiddleware::Retry will only be called if retry is needed
        retry_options = {
          max: 2,
          interval: 0.05,
          interval_randomness: 0.5,
          backoff_factor: 2
        }
        # Callback function for FaradayMiddleware::FollowRedirects will only be called if redirected to another url
        redirect_url_chain = []
        redirects_opts = {}
        redirects_opts[:callback] = proc do |old_response, new_response|
          redirect_url_chain << old_response.url.to_s
          new_url = new_response.url
          Rails.logger.debug("redirected from #{old_response.url} to #{new_response.url}")
        end
        redirects_opts[:limit] = redirect_limit
        ssl_options = { verify: false }
        conn = Faraday.new(ssl: ssl_options, headers: { user_agent: "curl" }) do |faraday|
          # faraday.use FaradayMiddleware::FollowRedirects, redirects_opts
          faraday.response :follow_redirects, redirects_opts
          faraday.request :retry, retry_options
          faraday.response :raise_error # raise Faraday::Error on status code 4xx or 5xx
          faraday.options.timeout = 30
          faraday.adapter Faraday.default_adapter
        end
        response = conn.get(@system.url)
        unless redirect_url_chain.empty?
          redirect_url_chain.each { |prev_url| @system.add_normalid_for_url(prev_url) }
        end
        if new_url.to_s != @system.url
          @system.url = new_url.to_s
        end
        @system.write_network_check(:homepage_url, true, "", response.status)
        @system.system_status = :online
        if parse_metadata_flag
          parse_metadata(response)
        end
      rescue Faraday::ResourceNotFound => e # 404
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :missing
      rescue Faraday::ForbiddenError => e # 403
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :unknown
      rescue Faraday::FollowRedirects::RedirectLimitReached => e
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :offline
      rescue Faraday::ClientError => e # 4xx
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :unknown
      rescue Faraday::TimeoutError => e
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :offline
      rescue Faraday::NilStatusError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{new_url_with_verb}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :unknown
      rescue Faraday::ServerError => e # 5xx
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :offline
      rescue Faraday::SSLError => e
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :offline
      rescue Faraday::ConnectionFailed => e
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        case e.message
        when /getaddrinfo: Name or service not known/
          @system.system_status = :missing
          @system.tag_list.add('host-not-found')
        when /getaddrinfo: No address associated with hostname/
          @system.system_status = :missing
          @system.tag_list.add('host-not-found')
        when /getaddrinfo: nodename nor servname provided, or not known/
          @system.system_status = :missing
          @system.tag_list.add('host-not-found')
        when /getaddrinfo: Temporary failure in name resolution/
          @system.system_status = :unknown
          @system.tag_list.add('host-not-found-temporarily')
        when /(execution expired)/
          @system.system_status = :offline
        else
          @system.system_status = :unknown
        end
      rescue Faraday::Error => e
        Rails.logger.warn("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :unknown
      rescue StandardError => e
        Rails.logger.error("#{e} for URL #{new_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :unknown
      end
      success @system
    end

    private

    def parse_metadata(response)
      begin
        Rails.logger.debug("Parsing metadata for URL #{@system.url}")
        begin
          doc = Nokogiri::HTML(response.body)
          doc.xpath('//meta[@name="twitter:title"]', '//meta[@property="og:title"]').each { |element| @system.metadata["title"] = element.attr("content") }
          doc.xpath('//meta[@name="twitter:description"]', '//meta[@property="og:description"]', '//meta[@name="description"]', '//meta[@name="Description"]').each { |element| @system.metadata["description"] = element.attr("content") }
          doc.xpath('//meta[@name="generator"]', '//meta[@name="Generator"]').each { |element| @system.metadata["generator"] = element.attr("content") }
        rescue Exception => e
          Rails.logger.warn "Unable to parse website body as XML for URL #{@system.url}"
        end
        service_result = Curation::PlatformAndGeneratorUpdaterService.call(@system)
        if service_result.success?
          @system = service_result.payload
        end
        if @system.unknown_platform?
          Rails.logger.debug "Attempting to match platform...."
          Platform.where(trusted: true).order(:match_order).each do |platform|
            unless @system.unknown_platform?
              break
            end
            if platform.matchers.present?
              platform.matchers.each do |matcher|
                begin
                  reg = eval matcher
                  if reg.match? response.body
                    @system.platform = platform
                    break
                  end
                rescue Exception => e
                  Rails.logger.warn("#{e} for matcher #{matcher} for @system: #{@system.id}")
                end
              end
            end
          end
        end
      rescue StandardError => e
        Rails.logger.warn("#{e} for URL #{@system.url}")
      end
    end

  end
end
