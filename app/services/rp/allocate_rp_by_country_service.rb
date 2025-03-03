# frozen_string_literal: true

module Rp
  class AllocateRpByCountryService < ApplicationService
    def call(system_id)
      begin
        system = System.includes(:network_checks, :repoids, :users).find(system_id)
        unless system.record_status_archived?
          rp = Organisation.rps.in_country(system.country_id).first unless Organisation.rps.in_country(system.country_id).blank?
          if rp
            system.rp = rp
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