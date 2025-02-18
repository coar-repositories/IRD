# frozen_string_literal: true
module Curation
  class PlatformAndGeneratorUpdaterService < ApplicationService

    def call(system)
      begin
        unless system.metadata.empty?
          if system.metadata['generator']
            system.generator = Generator.find_or_create_by!(name: system.metadata['generator'])
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
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in PlatformAndGeneratorUpdaterService: #{e.message}")
        failure e
      ensure
        system.platform_id = Platform.default_platform_id if system.platform_id.blank?
      end
    end
  end
end