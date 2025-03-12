# frozen_string_literal: true

module Curation
  class SystemRpUpdaterService < ApplicationService
    def call(system)
      begin
        if system.record_status_archived? || system.record_status_draft?
          system.rp = Organisation.default_rp_for_archived_records
        end
        success system
      rescue Exception => e
        Rails.logger.error("SystemRpUpdaterService: #{e.message}")
        failure e
      end
    end
  end
end