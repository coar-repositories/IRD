# frozen_string_literal: true

module Rp
  class AllocateRpByCountryService < ApplicationService
    def call(system_id)
      begin
        system = System.includes(:network_checks, :repoids, :users).find(system_id)
        if system.record_status_archived? || system.record_status_draft?
          system.rp = Organisation.default_rp
        elsif system.rp.nil? || system.rp == Organisation.default_rp
          rp = Organisation.rp_for_country(system.country_id)
          if rp
            system.rp = rp
          else
            system.rp = Organisation.default_rp
          end
        end
        success system
      rescue Exception => e
        Rails.logger.error("AllocateRpByCountryService failed: #{e.message}")
        failure e
      end
    end
  end
end