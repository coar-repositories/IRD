# frozen_string_literal: true

class ReindexSystemsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.debug "Reindexing systems..."
    System.reindex
    Rails.logger.info "Systems re-indexed OK"
  end
end
