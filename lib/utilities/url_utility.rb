# frozen_string_literal: true
module Utilities
  class UrlUtility
    require 'uri/http'

    def self.get_url_with_parent_folder_redirect_removed(url)
      begin
        unless URI(url).path.nil?
          url_section_to_remove = url[/[a-zA-Z0-9\-_]+\/\.\.\//]
          url.slice! url_section_to_remove unless url_section_to_remove.nil?
        end
         url
      rescue Exception => e
         url
      end
    end

    def self.get_url_string_with_port_80_removed(url)
      begin
        url = URI.parse(url)
        url.port = nil if url.port == 80
      rescue URI::InvalidURIError
        nil
      end
      url.to_s
    end

    def self.get_domain_from_url(url)
      begin
         PublicSuffix.parse(URI(url).host).domain.to_s.downcase
      rescue Exception => e
         nil
      end
    end

    def self.get_domain_from_normalid(normalid)
      begin
         PublicSuffix.parse(URI('http://' + normalid).host).domain.to_s.downcase
      rescue Exception => e
        Rails.logger.debug e
         nil
      end
    end

    def self.get_tld_from_url(url)
      begin
        url = url.delete_suffix('/')
        PublicSuffix.parse(URI(url).host).tld.split('.').last
      rescue Exception => e
        nil
      end
    end

    def self.get_url_without_trailing_slash(url)
      begin
        url.delete_suffix('/')
      rescue Exception => e
        url
      end
    end

    def self.get_normalised_url(url)
      begin
        uri = URI(url)
        normalised_url = uri.host
        normalised_url += uri.path if uri.path
        if normalised_url
          normalised_url.delete_suffix('/').downcase
        else
          nil
        end
      rescue Exception => e
        nil
      end
    end
  end
end
