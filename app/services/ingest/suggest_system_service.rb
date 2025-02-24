# frozen_string_literal: true

module Ingest
  class SuggestSystemService < ApplicationService
    require_relative "system_ingest_service"

    def call(params)
      begin
        suggested_system = ProposedSystem.new("user", nil, false, nil)
        suggested_system.name = params[:name]
        suggested_system.url = params[:url]
        suggested_system.system_category = params[:system_category]
        service_result = SystemIngestService.call(suggested_system)
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