# frozen_string_literal: true
module Utilities
  class HttpHeadersProcessor
    def self.process_tags_from_headers(tags, headers, context) #context is either :oai_pmh or :website
      begin
        if /cloudflare/.match? headers.to_s
          tags.add "cloudflare_#{context.to_s}"
        else
          tags.remove "cloudflare_#{context.to_s}"
        end
      rescue StandardError => e
        Rails.logger.warn e
      end
      tags
    end
  end
end
