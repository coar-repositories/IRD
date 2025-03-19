# frozen_string_literal: true

module Rp
  class AllocateRpByCountryService < ApplicationService
    def call(system_id,replace_existing_rp)
      begin
        system = System.includes(:network_checks, :repoids, :users).find(system_id)
        rp = Organisation.rp_for_country(system.country_id)
        system = AllocateRpService.call!(system.id, rp.id,replace_existing_rp).payload
        success system
      rescue Exception => e
        Rails.logger.error("AllocateRpByCountryService failed: #{e.message}")
        failure e
      end
    end
  end
end