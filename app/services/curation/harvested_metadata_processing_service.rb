# frozen_string_literal: true
module Curation
  class HarvestedMetadataProcessingService < ApplicationService
    def call(system)
      begin
        system.metadata = {} unless system.metadata.is_a? Hash
        if system.contact.blank? && system.metadata["oai_contact"].present?
          system.contact = system.metadata["oai_contact"]
        end
        if system.metadata["generator"]
          system.generator = Generator.find_or_create_by!(name: system.metadata["generator"])
          if system.generator && (system.unknown_platform? || system.generator.platform.trusted?)
            if system.generator.platform != system.platform
              Rails.logger.info "Updating platform for system #{system.id}..."
            end
            system.platform = system.generator.platform
            if system.generator.version != system.platform_version
              Rails.logger.info "Updating platform version for system #{system.id}..."
            end
            system.platform_version = system.generator.version
          end
        end
        if system.owner_id.blank?
          orgs = Organisation.where('domain = ?', Utilities::UrlUtility.get_domain_from_url(system.url)).limit(5)
          if orgs.count > 1
            Rails.logger.debug "Found potential owner(s) for system id: '#{system.id}'"
            orgs.each do |org|
              unless system.metadata['potential_owners'].kind_of?(Array)
                system.metadata['potential_owners'] = []
              end
              system.metadata['potential_owners'] << org.id
            end
          elsif orgs.count == 1
            system.owner = orgs[0]
            Rails.logger.info "Found owner for system id: '#{system.id}'"
          end
        else
          system.metadata.except!("potential_owners")
        end
        if system.description.blank? && system.metadata["description"].present?
          system.description = system.metadata["description"]
        end
        if system.metadata["title"].present?
          system.aliases << system.metadata["title"] unless system.aliases.include? system.metadata["title"]
        end
      end
      success system
    rescue Exception => e
      Rails.logger.error("Error in ContactProcessingService: #{e.message}")
      failure e
    end
  end
end
