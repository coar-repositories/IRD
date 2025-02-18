# frozen_string_literal: true

class RecordMakeUnderReviewJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
    system.change_record_status_to_under_review!
    system.save!
  end
end

