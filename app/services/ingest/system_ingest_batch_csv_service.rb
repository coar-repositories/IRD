# frozen_string_literal: true

module Ingest

  class NoOrganisationMatchesException < StandardError; end

  class MultipleOrganisationsMatchException < StandardError; end

  class SystemIngestBatchCsvService < ApplicationService
    require_relative "system_ingest_service"
    require "csv"
    require "fileutils"

    def call(data_file_path, record_source, dry_run)
      records_created = 0
      records_existing = 0
      errors = 0
      begin
        CSV.foreach(data_file_path, headers: true) do |row|
          begin
            proposed_system = ProposedSystem.new(record_source, row["local_id"], dry_run, nil)
            proposed_system.add_attribute("system_category", row["system_category"]) if row["system_category"]
            proposed_system.add_attribute("name", row["name"]) if row["name"]
            proposed_system.add_attribute("url", row["url"]) if row["url"]
            proposed_system.add_attribute("platform_id", row["platform"]) if row["platform"]
            proposed_system.add_attribute("platform_version", row["platform_version"]) if row["platform_version"]
            proposed_system.add_attribute("contact", row["contact"]) if row["contact"]
            proposed_system.add_attribute("oai_base_url", row["oai_base_url"]) if row["oai_base_url"]
            proposed_system.add_attribute("country_id", row["country_id"]) if row["country_id"]
            if row["repository_type"]
              case row["repository_type"]
              when "institutional"
                proposed_system.add_attribute("subcategory", :institutional_repository)
              when "generalist"
                proposed_system.add_attribute("subcategory", :generalist_repository)
              when "disciplinary"
                proposed_system.add_attribute("subcategory", :disciplinary_repository)
              when "governmental"
                proposed_system.add_attribute("subcategory", :governmental_repository)
              else
                proposed_system.add_attribute("subcategory", :unknown)
              end
            else
              proposed_system.add_attribute("subcategory", :unknown)
            end
            org = find_organisation(row["owner_ror"], row["owner_url"], row["owner_name"])
            proposed_system.add_attribute("owner_id", org.id) if org
            if row["identifiers"]
              identifiers = row["identifiers"].split("|")
              identifiers.each do |identifier|
                scheme, value = identifier.split(":")
                proposed_system.identifiers[scheme] = value
              end
            end
            # puts proposed_system.inspect
            service_result = SystemIngestService.call(proposed_system)
            if service_result.failure?
              if service_result.error.is_a?(SystemExistsIngestException)
                records_existing += 1
                raise service_result.error
              else
                errors += 1
                raise service_result.error
              end
            end
            records_created += 1
            system = service_result.payload
            Rails.logger.info(" Created system with ID: #{system.id}, Name: #{system.name}, URL: #{system.url}")
            Rails.logger.debug(" Created system: #{system.inspect}")
          rescue SystemExistsIngestException => e
            Rails.logger.warn "Found duplicate system: #{e.message}"
          rescue Exception => e
            Rails.logger.error "Error ingesting system with name '#{row["name"]}' - #{e.message}"
          end
        end
      end
      Rails.logger.info("Records created: #{records_created}")
      Rails.logger.info("Records existing: #{records_existing}")
      Rails.logger.info("Errors: #{errors}")
      success true
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
