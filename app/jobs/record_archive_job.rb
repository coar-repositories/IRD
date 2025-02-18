# frozen_string_literal: true

class RecordArchiveJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:media,:annotations,:users).find(system_id)
    system.archive!
    system.save!
  end
end

