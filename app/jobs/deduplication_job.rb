# frozen_string_literal: true

class DeduplicationJob < ApplicationJob
  queue_as :default

  def perform
    Curation::DeduplicationService.call!
  end
end
