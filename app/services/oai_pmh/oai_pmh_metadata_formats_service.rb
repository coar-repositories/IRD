# frozen_string_literal: true
require "nokogiri"

module OaiPmh
  class OaiPmhMetadataFormatsService < ApplicationService

    def call(system_id, redirect_limit = 6)
      begin
        @system = System.includes(:network_checks, :repoids,  :users).find(system_id)
        original_url = @system.oai_base_url
        unless original_url.present?
          Rails.logger.warn("OAI-PMH Base URL missing for OAI-PMH ListMetadataFormats #{original_url}")
          return system # return early if no OAI-PMH base URL
        end
        url_with_verb_list_metadata_formats = Utilities::OaiPmhUrlFormatter.with_verb_list_metadata_formats(original_url)
        Rails.logger.debug("Running OAI-PMH Check Formats on #{url_with_verb_list_metadata_formats}")
        conn = Utilities::HttpClientConnectionWrapper.new(redirect_limit)
        response = conn.get(url_with_verb_list_metadata_formats)
        doc = Nokogiri::XML(response.body)
        doc.remove_namespaces!

        @system.formats = {}
        doc.xpath("//metadataFormat").each do |format|
          @system.formats[format.at_xpath("metadataPrefix").text] = format.at_xpath("metadataNamespace").text if format.at_xpath("metadataNamespace")
        end
      rescue StandardError => e
        Rails.logger.warn "CheckOaiPmhFormatsJob: #{e.message}"
        failure e
      else
        success @system
      ensure
        begin
          @system.save!
        rescue Exception => e2
          Rails.logger.error("CheckOaiPmhFormatsJob: #{e2.message}")
        end
      end
    end
  end
end
