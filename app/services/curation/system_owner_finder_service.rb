# frozen_string_literal: true

module Curation
  class SystemOwnerFinderService < ApplicationService
    def call(system)
      begin
        if system.owner_id.blank?
          orgs = Organisation.where('domain = ?', Utilities::UrlUtility.get_domain_from_url(system.url)).limit(5)
          if orgs.count > 1
            Rails.logger.debug "Found potential owner(s) for system id: '#{system.id}'"
            orgs.each do |org|
              unless system.metadata['potential_owners'] && system.metadata['potential_owners'].kind_of?(Array)
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
        success system
      rescue Exception => e
        Rails.logger.error("SystemOwnerFinderService: #{e.message}")
        failure e
      end
    end
  end
end
