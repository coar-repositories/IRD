# frozen_string_literal: true

class AllocateRpJob < ApplicationJob
  queue_as :default

  def perform(system_id, rp_id, replace_existing_rp)
    system = Rp::AllocateRpService.call(system_id, rp_id, replace_existing_rp).payload
    system.save!
  end
end
