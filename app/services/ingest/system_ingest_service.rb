# frozen_string_literal: true

module Ingest
  SystemIngestServiceResultPayload = Struct.new(:system, :updated, :created)

  class SystemExistsIngestException < StandardError; end

  class SystemIngestService < ApplicationService

    def call(candidate_system)
      begin
        system = nil
        updated = false
        created = false
        system = System.find(candidate_system.get_attribute("id")) if candidate_system.get_attribute("id").present?
        if system
          Rails.logger.debug("Updating existing system with id '#{system.id}'....")
          system.assign_attributes(candidate_system.attributes)
          unless system.changes.empty?
            updated = true
            system.save! unless candidate_system.dry_run
            Rails.logger.info("System with id '#{system.id}' updated")
          end
          candidate_system.tags.each { |tag| system.tag_list.add(tag) }
          candidate_system.identifiers.each_pair do |scheme, value|
            if Repoid.find_by(system: system, identifier_scheme: scheme.to_sym, identifier_value: value).nil?
              Repoid.create!(system: system, identifier_scheme: scheme.to_sym, identifier_value: value) unless candidate_system.dry_run
              updated = true
              Rails.logger.debug("Repoids for system with id '#{system.id}' updated")
            end
          end
          unless updated
            Rails.logger.info("System with id '#{system.id}' unchanged")
          end
        else
          system = check_for_existing_system(candidate_system)
          if system
            raise SystemExistsIngestException.new("Found existing system:  <a href='/systems/#{system.id}'>#{system.name}</a>") # fail because input did not specify system ID to update, so this was an unexpected potential duplicate
          else
            system = System.new(candidate_system.attributes)
            candidate_system.tags.each { |tag| system.tag_list.add(tag) } if candidate_system.tags
            Rails.logger.debug("Creating new system with id '#{system.id}'....")
            system.save! unless candidate_system.dry_run
            Rails.logger.info("System with id '#{system.id}' created")
            candidate_system.identifiers.each_pair { |scheme, value| Repoid.find_or_create_by(system: system, identifier_scheme: scheme.to_sym, identifier_value: value) } unless candidate_system.dry_run
            Rails.logger.debug("Repoids for system with id '#{system.id}' updated")
            updated = false
            created = true
          end
        end
        success SystemIngestServiceResultPayload.new(system, updated, created)
      rescue SystemExistsIngestException => e
        Rails.logger.warn(e.message)
        failure e
      rescue Exception => e
        Rails.logger.error("Error ingesting system with name '#{candidate_system.get_attribute("name")}' - #{e.message}")
        failure e
      end
    end

    private

    def check_for_existing_system(candidate_system)
      begin
        if candidate_system.get_attribute("id").present?
          return System.find(candidate_system.get_attribute("id"))
        end
        candidate_system.identifiers.each_pair do |scheme, value|
          repoids = Repoid.where(identifier_scheme: scheme.to_sym, identifier_value: value)
          return System.find(repoids.first.system_id) if repoids.count == 1
        end
        normalised_url = Utilities::UrlUtility.get_normalised_url(candidate_system.get_attribute("url"))
        normal_id = Normalid.find_by_url(normalised_url)
        return System.find(normal_id.system_id) if normal_id
        nil
      rescue Exception => e
        Rails.logger.warn("Error finding existing system " + e.message)
        nil
      end
    end
  end
end