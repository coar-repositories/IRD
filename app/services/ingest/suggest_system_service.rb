# frozen_string_literal: true

module Ingest
  class SuggestSystemService < ApplicationService
    require_relative "system_ingest_service"

    def call(params)
      begin
        candidate_system = CandidateSystem.new("user", nil,  nil)
        candidate_system.add_attribute("name", params[:name])
        candidate_system.add_attribute("url", params[:url])
        candidate_system.add_attribute("system_category", params[:system_category])
        candidate_system.add_attribute("owner_id", params[:owner_id])
        service_result = SystemIngestService.call(candidate_system)
        if service_result.failure?
          if service_result.error.is_a?(SystemExistsIngestException)
            system = System.find_by_id(service_result.error.message)
            if system
              raise Exception.new("A repository with this URL already exists in IRD: <a href='/systems/#{system.id}'>#{system.name}</a>")
            else
              raise Exception.new("A repository with this URL already exists in IRD: #{service_result.error.message}")
            end
          else
            raise Exception.new("Error ingesting system: #{service_result.error.message}")
          end
        end
        success service_result.payload
      rescue Exception => e
        failure e
      end
    end
  end
end