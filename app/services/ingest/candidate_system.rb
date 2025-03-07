# frozen_string_literal: true

module Ingest
  class CandidateSystem
    attr_reader :record_source, :dry_run, :tags, :identifiers, :attributes

    def initialize(record_source, dry_run, tags)
      @record_source = record_source
      @dry_run = dry_run
      @tags = tags
      @identifiers = {}
      @attributes = {}
    end

    def add_attribute(key, value)
      value.strip! if value.is_a? String
      @attributes[key] = value
    end

    def add_identifier(scheme, value)
      @identifiers[scheme] = value
    end

    def get_attribute(key)
      @attributes[key]
    end

    def normalise_attributes!
      @attributes["media_types"] = [] if @attributes["media_types"].nil?
      @tags = [] if @tags.nil?
    end
  end
end
