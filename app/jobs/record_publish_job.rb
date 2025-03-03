# frozen_string_literal: true

class RecordPublishJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:users).find(system_id)
    system.record_status = :published
    system.save!
  end
end
