# frozen_string_literal: true

class AllocateRpJob < ApplicationJob
  queue_as :default

  def perform(system_id, rp_id)
    system = Rp::AllocateRpService.call(system_id, rp_id).payload
    system.save!
  end
end
