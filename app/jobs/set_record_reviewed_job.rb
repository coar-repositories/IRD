# frozen_string_literal: true

class SetRecordReviewedJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
    system.mark_reviewed!
    system.save!
  end
end
