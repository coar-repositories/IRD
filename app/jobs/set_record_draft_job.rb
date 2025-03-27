# frozen_string_literal: true

class SetRecordDraftJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:users).find(system_id)
    system.draft!
    system.save!
  end
end

