# frozen_string_literal: true

module Ingest
  class ProposedSystem
    attr_accessor :local_id, :dry_run, :tags, :name, :url, :record_source, :system_category, :oai_base_url, :owner_id, :identifiers, :platform_id, :platform_version, :contact, :subcategory, :country_id

    def initialize(record_source, local_id, dry_run, tags)
      @record_source = record_source
      @local_id = local_id
      @dry_run = dry_run
      @tags = tags
      @name, @url, @system_category, @oai_base_url, @owner_id, @platform_id, @platform_version, @contact, @subcategory, @country_id = nil
      @identifiers = {}
    end

    def attributes
      { name: @name, url: @url, record_source: @record_source, system_category: @system_category, oai_base_url: @oai_base_url, owner_id: @owner_id, platform_id: @platform_id, platform_version: @platform_version, contact: @contact, subcategory: @subcategory, country_id: @country_id }
    end
  end

  class SystemExistsIngestException < StandardError; end

  class SystemIngestService < ApplicationService

    def call(proposed_system)
      begin
        existing_system = check_for_existing_system(proposed_system)
        if existing_system
          update_repoids(existing_system, proposed_system)
          failure SystemExistsIngestException.new(existing_system.id)
        else
          system = System.new(proposed_system.attributes)
          system.save! unless proposed_system.dry_run
          system.tag_list = proposed_system.tags unless proposed_system.dry_run
          update_repoids(system, proposed_system)
          success system
        end
      rescue Exception => e
        Rails.logger.error("Error ingesting system with name '#{proposed_system.name}' - #{e.message}")
        failure e
      end
    end

    private

    def update_repoids(system, proposed_system)
      unless proposed_system.local_id.blank? || proposed_system.record_source.blank?
        begin
          # Rails.logger.debug "Adding Repoid for system #{system.id} - #{proposed_system.record_source} - #{proposed_system.local_id}"
          Repoid.create!(system: system, identifier_scheme: proposed_system.record_source.to_sym, identifier_value: proposed_system.local_id) unless proposed_system.dry_run
        rescue Exception => e
          Rails.logger.warn("Error creating Repoid for system #{system.id} - #{e.message}")
        end
      end
      unless proposed_system.identifiers.blank?
        proposed_system.identifiers.each_pair do |scheme, value|
          begin
            # Rails.logger.debug "Adding Repoid for system #{system.id} - #{proposed_system.record_source} - #{proposed_system.local_id}"
            Repoid.create!(system: system, identifier_scheme: scheme.to_sym, identifier_value: value) unless proposed_system.dry_run
          rescue Exception => e
            Rails.logger.warn("Error creating Repoid for system #{system.id} - #{e.message}")
          end
        end
      end
    end

    def check_for_existing_system(proposed_system)
      begin
        if proposed_system.local_id
          repo_id = Repoid.find_by(identifier_scheme: proposed_system.record_source.to_sym, identifier_value: proposed_system.local_id)
          return System.find(repo_id.system_id) if repo_id
        end
        if proposed_system.identifiers.present?
          proposed_system.identifiers.each_pair do |scheme, value|
            repo_id = Repoid.find_by(identifier_scheme: scheme.to_sym, identifier_value: value)
            # Rails.logger.debug("Found existing system with identifier #{scheme} - #{value}") if repo_id
            return System.find(repo_id.system_id) if repo_id
          end
        end
        normalised_url = Utilities::UrlUtility.get_normalised_url(proposed_system.url)
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