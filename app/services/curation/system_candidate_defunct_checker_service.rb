# frozen_string_literal: true
module Curation
  class SystemCandidateDefunctCheckerService < ApplicationService
    def call(system)
      begin
        nc_homepage = system.network_checks.homepage_url_failed.first
        nc_oai = system.network_checks.oai_pmh_identify_failed.first
        if nc_homepage&.errors_past_threshold? && nc_oai&.errors_past_threshold?
          system.add_annotation(Annotation.find("candidate-defunct"))
          system.change_record_status_to_under_review! if system.record_status_published?
        else
          system.remove_annotation(Annotation.find("candidate-defunct"))
        end
        if nc_oai&.errors_past_threshold?
          system.add_annotation(Annotation.find("candidate-out-of-scope"))
          system.change_record_status_to_under_review! if system.record_status_published?
        else
          system.remove_annotation(Annotation.find("candidate-out-of-scope"))
        end
      end
      success system
    rescue Exception => e
      Rails.logger.error("Error in CheckCandidateDefunctService: #{e.message}")
      failure e
    end
  end
end
