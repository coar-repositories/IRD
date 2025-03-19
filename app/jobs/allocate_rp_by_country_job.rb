# frozen_string_literal: true

class AllocateRpByCountryJob < ApplicationJob
  queue_as :default

  def perform(system_id, replace_existing_rp)
    system = Rp::AllocateRpByCountryService.call(system_id, replace_existing_rp).payload
    system.save!
  end

end
