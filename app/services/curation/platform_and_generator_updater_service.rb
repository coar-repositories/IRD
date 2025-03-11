# frozen_string_literal: true
module Curation
  class PlatformAndGeneratorUpdaterService < ApplicationService
    def call(system)
      begin
        if system.metadata["generator"]
          system.generator = Generator.find_or_create_by!(name: system.metadata["generator"])
          if system.generator && (system.unknown_platform? || system.generator.platform.trusted?)
            Rails.logger.info "Updating platform for system #{system.id}..." if system.generator.platform != system.platform
            system.platform = system.generator.platform
            if system.generator.version != system.platform_version
              Rails.logger.info "Updating platform version for system #{system.id}..."
            end
            system.platform_version = system.generator.version
          end
        else
          system.generator = nil
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in PlatformAndGeneratorUpdaterService: #{e.message}")
        failure e
      end
    end
  end
end
