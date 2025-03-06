# frozen_string_literal: true

module Rp
  class AllocateRpService < ApplicationService

    def call(system_id, rp_id)
      begin
        system = System.includes(:network_checks, :repoids,  :users).find(system_id)
        system.rp = Organisation.find(rp_id)
        success system
      rescue Exception => e
        Rails.logger.error e.message
        failure e
      end
    end
  end
end