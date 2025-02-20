# frozen_string_literal: true

module Curation
  class OaiPmhBaseUrlNormalisingService < ApplicationService
    require "addressable/uri"
    def call(system)
      begin
        unless system.oai_base_url.blank?
          new_base_url = Addressable::URI.parse(system.oai_base_url)
          params = new_base_url.query_values
          if params
            params.delete("verb")
          end
          params = nil if params.blank?
          new_base_url.query_values = params
          system.oai_base_url = new_base_url.to_s
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in OaiPmhBaseUrlNormalisingService: #{e.message}")
        failure e
      end
    end
  end
end