# frozen_string_literal: true

class RecordMakeDraftJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
    system.make_draft!
    system.save!
  end
end

