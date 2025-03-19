# frozen_string_literal: true

module Rp
  class AllocateRpService < ApplicationService

    def call(system_id, rp_id, replace_existing_rp = false)
      begin
        system = System.includes(:network_checks, :repoids, :users).find(system_id)
        if replace_existing_rp || (system.rp == Organisation.default_rp_id || system.rp == nil)
          system.rp = Organisation.find(rp_id)
        end
        success system
      rescue Exception => e
        Rails.logger.error e.message
        failure e
      end
    end
  end
end