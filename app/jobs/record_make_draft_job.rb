# frozen_string_literal: true

class RecordMakeDraftJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:users).find(system_id)
    system.record_status = :draft
    system.save!
  end
end

