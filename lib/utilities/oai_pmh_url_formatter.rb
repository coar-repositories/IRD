# frozen_string_literal: true
module Utilities
  class OaiPmhUrlFormatter
    require "addressable/uri"

    def self.with_verb_identify(base_url)
      base_url_with_verb = Addressable::URI.parse(base_url)
      base_url_with_verb.query_values = {"verb": "Identify"}
      base_url_with_verb
    end

    def self.with_verb_list_metadata_formats(base_url)
      base_url_with_verb = Addressable::URI.parse(base_url)
      base_url_with_verb.query_values = {"verb": "ListMetadataFormats"}
      base_url_with_verb
    end
    
    def self.without_verbs(base_url)
      base_url_with_verbs_removed = Addressable::URI.parse(base_url)
      base_url_with_verbs_removed.query_values = base_url_with_verbs_removed.query_values.except("verb") unless base_url_with_verbs_removed.query_values.nil?
      if base_url_with_verbs_removed.query_values.present? && base_url_with_verbs_removed.query_values.empty?
        base_url_with_verbs_removed.query_values = nil # removes extraneous '?' from end of URL
      end
      base_url_with_verbs_removed
    end

    def self.without_any_query_params(base_url)
      Addressable::URI.parse(base_url).omit(:query)
    end
  end
end