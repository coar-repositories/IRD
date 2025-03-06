# frozen_string_literal: true
module Curation
  class SystemCandidateDefunctCheckerService < ApplicationService
    def call(system)
      begin
        nc_homepage = system.network_checks.homepage_url_failed.first
        nc_oai = system.network_checks.oai_pmh_identify_failed.first
        if nc_homepage&.errors_past_threshold? && nc_oai&.errors_past_threshold?
          system.label_list.add("candidate-defunct")
          system.review! if system.record_status_published?
        else
          system.label_list.remove("candidate-defunct")
        end
        if nc_oai&.errors_past_threshold?
          system.label_list.add("candidate-out-of-scope")
          system.review! if system.record_status_published?
        else
          system.label_list.remove("candidate-out-of-scope")
        end
      end
      success system
    rescue Exception => e
      Rails.logger.error("Error in CheckCandidateDefunctService: #{e.message}")
      failure e
    end
  end
end
