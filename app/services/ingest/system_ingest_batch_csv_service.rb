# frozen_string_literal: true
require_relative "system_ingest_service"

module Ingest

  class NoOrganisationMatchesException < StandardError; end

  class MultipleOrganisationsMatchException < StandardError; end

  class SystemIngestBatchCsvService < ApplicationService
    require "csv"
    require "fileutils"

    def call(data, record_source, tags, dry_run, user)
      batch_report = SystemIngestBatchReport.new
      begin
        service_result = SystemIngestBatchCsvValidationService.call(data)
        if service_result.failure?
          raise service_result.error
        end
        CSV.parse(data, headers: true).each_with_index do |row,row_number|
          begin
            # [ :owner_id, :owner_homepage, :owner_ror, :owner_name, :repository_type, :, :, :, :
            candidate_system = CandidateSystem.new(record_source, dry_run, tags)
            candidate_system.add_attribute("id", row["id"])
            candidate_system.add_attribute("system_category", (row["system_category"] ||= Rails.configuration.ird[:default_attributes][:system_category]))
            candidate_system.add_attribute("subcategory", row["repository_type"])
            candidate_system.add_attribute("name", row["name"])
            candidate_system.add_attribute("url", row["homepage"])
            candidate_system.add_attribute("platform_id", row["software"])
            candidate_system.add_attribute("platform_version", row["software_version"])
            candidate_system.add_attribute("contact", row["contact"])
            candidate_system.add_attribute("oai_base_url", row["oai_base_url"])
            candidate_system.add_attribute("primary_subject", row["primary_subject"])
            candidate_system.add_attribute("record_status", row["record_status"])
            candidate_system.add_attribute("media_types", row["media_types"].split("|")) if row["media_types"] && !row["media_types"].blank?
            org = find_organisation(row["owner_ror"], row["owner_url"], row["owner_name"])
            candidate_system.add_attribute("owner_id", org.id) if org
            if row["other_registry_identifiers"]
              identifiers = row["other_registry_identifiers"].strip.split("|")
              identifiers.each do |identifier|
                scheme, value = identifier.split(":")
                candidate_system.add_identifier(scheme, value)
              end
            end
            candidate_system.normalise_attributes!
            service_result = SystemIngestService.call(candidate_system,user)
            if service_result.failure?
              if service_result.error.is_a?(SystemExistsIngestException)
                batch_report.add_record_not_updated(BatchItemReport.new(row_number, service_result.error.message))
              else
                batch_report.add_error(BatchItemReport.new(row_number, service_result.error.message))
              end
              raise service_result.error
            else
              if service_result.payload.updated
                batch_report.add_record_updated(service_result.payload.system.id)
              elsif service_result.payload.created
                  batch_report.add_record_created(service_result.payload.system.id)
              else
                batch_report.add_record_unchanged(BatchItemReport.new(row_number, "System unchanged"))
              end
            end
          rescue SystemExistsIngestException => e
            Rails.logger.warn "Error batch ingesting system with name '#{row["name"]}' - #{e.message}"
          rescue Exception => e
            Rails.logger.error "Error batch ingesting system with name '#{row["name"]}' - #{e.message}"
          end
        end
      end
      Rails.logger.info("Batch ingest operation completed: #{batch_report.report}")
      success batch_report
    rescue Exception => e
      failure e
    end

    private

    def find_organisation(ror, url, name)
      begin
        org = nil
        org = Organisation.find_by_ror(ror) unless ror.blank?
        if org
          return org
        end
        unless url.blank?
          org = Organisation.find_by_website(url)
          if org
            return org
          end
          orgs = Organisation.where(domain: Utilities::UrlUtility.get_domain_from_url(url))
          if orgs.count == 1
            org = orgs.first
            return org
          elsif orgs.count > 1
            Rails.logger.warn("Multiple matches for organisation finder")
          end
        end
        unless name.blank?
          orgs = Organisation.where("name = ?", name)
          if orgs.count == 1
            org = orgs.first
            return org
          elsif orgs.count > 1
            Rails.logger.warn("Multiple matches for organisation finder")
          end
        end
        unless org
          Rails.logger.warn("No single match for organisation finder (#{name}, #{url}, #{ror})")
        end
        org
      rescue Exception => e
        Rails.logger.error("Error in OrganisationFinderService: #{e.message}")
        nil
      end
    end
  end
end
