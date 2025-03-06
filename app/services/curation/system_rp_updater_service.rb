# frozen_string_literal: true

module Curation
  class SystemRpUpdaterService < ApplicationService
    def call(system)
      begin
        if system.record_status_archived?
          system.rp = Organisation.default_rp_for_archived_records
        elsif system.rp.blank? || system.rp == Organisation.default_rp_for_archived_records || system.record_status_draft?
          system.rp = Organisation.default_rp_for_live_records
        end
        success system
      rescue Exception => e
        Rails.logger.error("SystemRpUpdaterService: #{e.message}")
        failure e
      end
    end
  end
end