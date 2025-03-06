# frozen_string_literal: true

module Curation
  class OaiPmhBaseUrlNormalisingService < ApplicationService
    def call(system)
      begin
        unless system.oai_base_url.blank?
          system.oai_base_url = Utilities::OaiPmhUrlFormatter.without_verbs(system.oai_base_url).to_s
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in OaiPmhBaseUrlNormalisingService: #{e.message}")
        failure e
      end
    end
  end
end