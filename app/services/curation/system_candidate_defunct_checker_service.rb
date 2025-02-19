# frozen_string_literal: true
module Curation
  class SystemCandidateDefunctCheckerService < ApplicationService
    def call(system)
      begin
        nc = system.network_checks.homepage_url_failed.first
        if nc && nc.failures >= Rails.application.config.ird[:network_check_failure][:error_count_threshold] && nc.error_duration >= Rails.application.config.ird[:network_check_failure][:error_duration_threshold]
          system.add_annotation(Annotation.find("candidate-defunct"))
          system.change_record_status_to_under_review!
        else
          system.remove_annotation(Annotation.find("candidate-defunct"))
        end
        nc = system.network_checks.oai_pmh_identify_failed.first
        if nc && nc.failures >= Rails.application.config.ird[:network_check_failure][:error_count_threshold] && nc.error_duration >= Rails.application.config.ird[:network_check_failure][:error_duration_threshold]
          system.add_annotation(Annotation.find("candidate-out-of-scope"))
          system.change_record_status_to_under_review!
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
