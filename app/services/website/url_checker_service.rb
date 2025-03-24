# frozen_string_literal: true
require "nokogiri"

module Website
  class UrlCheckerService < ApplicationService

    def call(system_id, parse_metadata_flag, redirect_limit = 6)
      begin
        @system = System.includes(:network_checks, :repoids, :users).find(system_id)
        original_url = @system.url
        if @system.metadata["html_redirected_url"].present?
          @system.url = @system.metadata["html_redirected_url"]
          @system.metadata.except!("html_redirected_url")
        end
        conn = Utilities::HttpClientConnectionWrapper.new(redirect_limit)
        response = conn.get(@system.url)
        unless conn.redirect_url_chain.empty?
          conn.redirect_url_chain.each { |prev_url| @system.add_normalid_for_url(prev_url) }
        end
        if conn.new_url.to_s != @system.url
          @system.url = conn.new_url.to_s
        end
        @system.write_network_check(:homepage_url, true, "", response.status)
        @system.system_status = :online
        Utilities::HttpHeadersProcessor.process_tags_from_headers(@system.tag_list, response.headers, :website)
        if parse_metadata_flag
          parse_metadata(response)
        end
      rescue Faraday::ResourceNotFound => e # 404
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :missing
        failure e
      rescue Faraday::ForbiddenError => e # 403
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :online
        Utilities::HttpHeadersProcessor.process_tags_from_headers(@system.tag_list, e.response[:headers], :website)
        failure e
      rescue Faraday::FollowRedirects::RedirectLimitReached => e
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :offline
        failure e
      rescue Faraday::ClientError => e # 4xx
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :unknown
        failure e
      rescue Faraday::TimeoutError => e
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :offline
        failure e
      rescue Faraday::NilStatusError => e
        Rails.logger.warn("#{e} for OAI-PMH Identify #{original_url}")
        @system.write_network_check(:oai_pmh_identify, false, e.message, 0)
        @system.oai_status = :unknown
        failure e
      rescue Faraday::ServerError => e # 5xx
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, e.response[:status])
        @system.system_status = :offline
        failure e
      rescue Faraday::SSLError => e
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :offline
        failure e
      rescue Faraday::ConnectionFailed => e
        Rails.logger.warn("#{e} for URL #{original_url}")
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
        failure e
      rescue Faraday::Error => e
        Rails.logger.warn("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :unknown
        failure e
      rescue StandardError => e
        Rails.logger.error("#{e} for URL #{original_url}")
        @system.write_network_check(:homepage_url, false, e.message, 0)
        @system.system_status = :unknown
        failure e
      else
        success @system
      ensure
        begin
          @system.save!
        rescue Exception => e2
          Rails.logger.error("CheckWebsite: #{e2.message}")
        end
      end
    end

    private

    def parse_metadata(response)
      begin
        Rails.logger.debug("Parsing metadata for URL #{@system.url}")
        begin
          doc = Nokogiri::HTML(response.body)
          begin
            html_redirect_element = doc.xpath('//meta[@http-equiv="refresh"]')
            html_redirect_element_url = html_redirect_element.attr("content").text
            @system.metadata["html_redirected_url"] = html_redirect_element_url.split(';')[1].split('=')[1].strip
          rescue Exception => e
            # don't worry about it!
            @system.metadata.except!("html_redirected_url") if @system.metadata["html_redirected_url"].present?
          end
          doc.xpath('//meta[@name="twitter:title"]', '//meta[@property="og:title"]').each { |element| @system.metadata["title"] = element.attr("content") }
          doc.xpath('//meta[@name="twitter:description"]', '//meta[@property="og:description"]', '//meta[@name="description"]', '//meta[@name="Description"]').each { |element| @system.metadata["description"] = element.attr("content") }
          generator_elements = doc.xpath('//meta[@name="generator"]', '//meta[@name="Generator"]')
          if generator_elements.empty?
            @system.metadata.except!("generator")
          else
            generator_elements.each { |element| @system.metadata["generator"] = element.attr("content") }
          end
        rescue Exception => e
          Rails.logger.warn "Unable to parse website body for URL #{@system.url}: #{e}"
        end
        service_result = Curation::PlatformAndGeneratorUpdaterService.call(@system)
        if service_result.success?
          @system = service_result.payload
        end
        if @system.unknown_platform?
          Rails.logger.debug "Attempting to match platform...."
          Platform.where(trusted: true).order(:match_order).each do |platform|
            break unless @system.unknown_platform?
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
