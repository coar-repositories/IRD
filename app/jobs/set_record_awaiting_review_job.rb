# frozen_string_literal: true

class SetRecordAwaitingReviewJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:users).find(system_id)
    system.awaiting_review!
    system.save!
  end
end
