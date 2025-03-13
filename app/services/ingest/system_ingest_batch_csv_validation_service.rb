# frozen_string_literal: true

module Ingest

  class CsvRowError
    attr_accessor :row_number, :message

    def initialize(row_number, message)
      @row_number = row_number
      @message = message
    end

    def to_s
      "Row #{row_number}: #{message}"
    end
  end

  class CsvValidationException < StandardError; end

  class SystemIngestBatchCsvValidationService < ApplicationService
    # Header_row = %w[id name system_category homepage owner_id owner_homepage contact owner_ror owner_name repository_type system_status software software_version country responsible_organisation other_registry_identifiers oai_base_url oai_status media_types primary_subject reviewed metadata_formats record_status]
    # Header_row = System.machine_readable_attributes.attributes.collect { |attribute| attribute.label.to_s if attribute.include_for_ingest }.compact
    Header_row = System.machine_readable_attributes.labels(false)
    def call(data)
      errors = []
      begin
        puts Header_row.inspect
        csv_headers = CSV.parse_line(data)
        csv_headers.each_with_index do |cell, i|
          errors << CsvRowError.new(0, "Column heading '#{cell}' (column #{i}) is not a valid column heading") unless Header_row.include? cell.to_sym
        end
        CSV.parse(data, headers: true).each_with_index do |row, row_number|
          begin
            errors << CsvRowError.new(row_number, "'name' must not be blank") if row["name"].blank?
            errors << CsvRowError.new(row_number, "'homepage' must be a valid URL") unless Utilities::UrlUtility.validate_url row["homepage"]
            errors << CsvRowError.new(row_number, "'system_category' must have the value 'repository'") unless System.system_categories.keys.include? row["system_category"]
            errors << CsvRowError.new(row_number, "'system_status' must be one of: [#{System.system_statuses.keys.join('|')}]") unless System.system_statuses.keys.include? row["system_status"]
            errors << CsvRowError.new(row_number, "'record_status' must be one of: [#{System.record_statuses.keys.join('|')}]") unless System.record_statuses.keys.include? row["record_status"]
            errors << CsvRowError.new(row_number, "'repository_type' must be one of: [#{System.subcategories.keys.join('|')}]") unless System.subcategories.keys.include? row["repository_type"]
          end
        end
        if errors.empty?
          success true
        else
          errors_to_log = "Found #{errors.length} errors in CSV data - showing up to first 20 errors: \n"
          errors[..19].each { |error| errors_to_log += error.to_s + "\n" }
          failure CsvValidationException.new(errors_to_log)
        end
      rescue Exception => e
        failure e
      end
    end
  end
end