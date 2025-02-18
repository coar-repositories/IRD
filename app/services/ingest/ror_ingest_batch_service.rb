# frozen_string_literal: true

module Ingest
  class RorIngestBatchService < ApplicationService
    require 'json'

    def call(data_file_path)
      begin
        updated_count = 0
        created_count = 0
        error_count = 0
        data = JSON.parse(File.read(data_file_path))
        data.each do |record|
          begin
            record_hash = {}
            record_hash[:id] = record['id']
            locations = record['locations']
            if locations && locations.count > 0
              geonames_details = locations[0]['geonames_details']
              if geonames_details
                record_hash[:country_code] = geonames_details['country_code']
                record_hash[:location] = geonames_details['name']
                record_hash[:latitude] = geonames_details['lat']
                record_hash[:longitude] = geonames_details['lng']
              end
            end
            links = record['links']
            if links && links.count > 0
              links.each do |link|
                if link['type'] == 'website'
                  record_hash[:website] = link['value']
                  break
                end
              end
            end
            record_hash[:aliases] = []
            names = record['names']
            if names && names.count > 0
              names.each do |name|
                if name['types'].include? 'ror_display'
                  record_hash[:name] = name['value']
                else
                  record_hash[:aliases] << name['value']
                end
              end
            end
            attributes = {
              ror: record_hash[:id],
              name: record_hash[:name],
              aliases: record_hash[:aliases],
              country: Country.find(record_hash[:country_code]),
              location: record_hash[:location],
              latitude: record_hash[:latitude].to_f,
              longitude: record_hash[:longitude].to_f,
              website: record_hash[:website]
            }
            org = Organisation.find_by(ror: record_hash[:id])
            if org
              org.update(attributes)
              updated_count += 1
              Rails.logger.debug "Updated Organisation with ROR ID: #{org.ror} OK"
            else
              org = Organisation.create(attributes)
              created_count += 1
              Rails.logger.info "Created Organisation with ROR ID: #{org.ror}..."
            end
          rescue Exception => e
            Rails.logger.warn("Error processing #{record['id']}: #{e.message}")
            error_count += 1
          end
        end
      end
      Rails.logger.info "Processed #{data.count} records"
      Rails.logger.info "#{created_count} records created"
      Rails.logger.info "#{updated_count} records updated"
      Rails.logger.info "#{error_count} errors"
      success true
    rescue Exception => e2
      Rails.logger.error e2.message
      failure e2
    end
  end
end
