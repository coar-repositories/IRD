# frozen_string_literal: true

module Ingest
  class SystemExistsIngestException < StandardError; end

  class SystemIngestService < ApplicationService

    def call(new_system_attributes, local_id, dry_run, tags)
      begin
        existing_system = check_for_existing_system(new_system_attributes, local_id)
        if existing_system
          exception = SystemExistsIngestException.new(existing_system.id)
          failure exception
        else
          system = System.new(new_system_attributes)
          system.tag_list = tags
          unless dry_run
            system.save!
            unless local_id.blank? || new_system_attributes[:record_source].blank?
              Repoid.create!(system: system, identifier_scheme: new_system_attributes[:record_source].to_sym, identifier_value: local_id)
            end
          end
          success system
        end
      rescue Exception => e
        Rails.logger.error("Error ingesting system with name '#{new_system_attributes[:name]}' - #{e.message}")
        failure e
      end
    end

    private

    def check_for_existing_system(new_system_attributes, local_id)
      begin
        if local_id
          record_source = new_system_attributes[:record_source]
          repo_id = Repoid.find_by(identifier_scheme: record_source.to_sym, identifier_value: local_id)
          return System.find(repo_id.system_id) if repo_id
        end
        normalised_url = Utilities::UrlUtility.get_normalised_url(new_system_attributes[:url])
        puts normalised_url
        normal_id = Normalid.find_by_url(normalised_url)
        puts normal_id.inspect
        return System.find(normal_id.system_id) if normal_id
        nil
      rescue Exception => e
        Rails.logger.warn("Error finding existing system " + e.message)
        nil
      end
    end
  end
end