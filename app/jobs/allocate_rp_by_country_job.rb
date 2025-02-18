# frozen_string_literal: true

class AllocateRpByCountryJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = Rp::AllocateRpByCountryService.call(system_id).payload
    system.save!
  end

end
