# frozen_string_literal: true

module Curation
  class SystemMetadataFormatAssociationService < ApplicationService
    def call(system)
      begin
        system.metadata_formats.clear
        system.formats.each do |format|
          MetadataFormat.order(:match_order).each do |mf|
            if mf.matchers.present?
              mf.matchers.each do |matcher|
                begin
                  reg = eval matcher
                  if reg.match? format[1]
                    system.metadata_formats << mf unless system.metadata_formats.include?(mf)
                    break
                  end
                rescue Exception => e
                  # Rails.logger.warn("#{e} for matcher #{matcher} for @system: #{system.id}")
                end
              end
            end
          end
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in SystemMetadataFormatAssociationService: #{e.message}")
        failure e
      end
    end
  end
end
