# frozen_string_literal: true

module Ingest

  class NoOrganisationMatchesException < StandardError; end
  class MultipleOrganisationsMatchException < StandardError; end

  class SystemIngestBatchService < ApplicationService
    require 'csv'
    require 'fileutils'

    def call(data_file_path, record_source, dry_run)
      records_created = 0
      records_existing = 0
      errors = 0
      begin
        CSV.foreach(data_file_path, headers: true) do |row|
          begin
            local_id = row['local_id']
            org = find_organisation(row['owner_ror'], row['owner_url'], row['owner_name'])
            aliases = []
            aliases = row['aliases'].split('|') if row['aliases']

            primary_subject = :unknown
            primary_subject = row['primary_subject'].to_sym if row['primary_subject']

            system_category = :unknown
            system_category = System.system_categories[row['system_category'].to_sym] if row['system_category']

            subcategory = :unknown
            subcategory = row['system_type'].to_sym if row['system_type']

            attributes = {
              name: row["name"],
              url: row["url"],
              record_source: record_source,
              system_category: system_category,
              oai_base_url: row['oai_base_url'],
              description: row['description'],
              aliases: aliases,
              owner: org,
              primary_subject: primary_subject,
              subcategory: subcategory,
              contact: row['contact'],
              platform: Platform.find_by_id(row['platform'])
            }
            service_result = SystemIngestService.call(attributes, local_id, dry_run, nil)

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
            if row['media']
              row['media'].split('|').each do |medium|
                system.add_medium Medium.find(medium)
              end
            end
            Rails.logger.info(" Created system: #{system.id}")
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
        unless org.present?
          org = Organisation.find_by_domain(Utilities::UrlUtility.get_domain_from_url(url)) unless url.blank?
        end
        unless org.present? || name.blank?
          orgs = Organisation.where("name = ?", name)
          if orgs.count == 1
            org = orgs.first
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
        return nil
      end
    end
  end

end