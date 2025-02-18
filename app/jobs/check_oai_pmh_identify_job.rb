class CheckOaiPmhIdentifyJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = OaiPmh::OaiPmhIdentifyService.call(system_id).payload
    system.save!
  end

end
