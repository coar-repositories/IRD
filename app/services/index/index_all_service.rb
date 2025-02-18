# frozen_string_literal: true

module Index
  class IndexAllService < ApplicationService

    def call
      begin
        Rails.logger.debug "Reindexing systems..."
        System.reindex
        Rails.logger.info "Systems re-indexed OK"

        Rails.logger.debug "Reindexing organisations..."
        Organisation.reindex
        Rails.logger.info "Organisations re-indexed OK"

        Rails.logger.debug "Reindexing users..."
        User.reindex
        Rails.logger.info "Users re-indexed OK"
        success true
      rescue Exception => e
        failure e
      end
    end
  end
end