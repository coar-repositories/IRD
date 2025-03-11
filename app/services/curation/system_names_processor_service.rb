# frozen_string_literal: true

module Curation
  class SystemNamesProcessorService < ApplicationService
    def call(system)
      begin
        if system.short_name.blank?
          system.aliases.each do |a|
            if a.size < 20 || !a.include?(' ')
              system.short_name = a
            end
          end
        end
        success system
      rescue Exception => e
        Rails.logger.error("Error in SystemNamesProcessorService: #{e.message}")
        failure e
      end
    end
  end
end