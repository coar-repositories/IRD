# frozen_string_literal: true
module Rp
  class RemoveRpStatusService < ApplicationService

    def call(org)
      begin
        unless org.id == Organisation.default_rp_for_archived_records_id || org.id == Organisation.default_rp_for_published_records_id
          org.rp = false
          org.responsibilities.each do |system|
            remove_rp_status(system)
          end
        end
        success org
      rescue StandardError => e
        Rails.logger.error e.message
        failure e
      end
    end

    private

    def remove_rp_status(system)
      if system.record_status_archived? || system.record_status_draft?
        system = AllocateRpService.call!(system.id, Organisation.default_rp_for_archived_records_id).payload
      else
        system = AllocateRpService.call!(system.id, Organisation.default_rp_for_published_records_id).payload
      end
      system.save!
    end
  end
end