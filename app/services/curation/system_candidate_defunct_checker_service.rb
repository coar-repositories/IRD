# frozen_string_literal: true
module Curation
  class SystemCandidateDefunctCheckerService < ApplicationService
    def call(system)
      begin
        if system.has_homepage_url_failures_past_threshold?
          system.add_annotation(Annotation.find("candidate-defunct"))
        elsif system.has_oai_pmh_identify_failures_past_threshold?
          system.add_annotation(Annotation.find("candidate-out-of-scope"))
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in CheckCandidateDefunctService: #{e.message}")
        failure e
      end
    end
  end
end