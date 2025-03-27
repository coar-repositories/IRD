# frozen_string_literal: true

class SetRecordArchivedJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = System.includes(:network_checks,:repoids,:users).find(system_id)
    system.archive!
    system.save!
  end
end

