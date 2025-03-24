class CheckOaiPmhIdentifyJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    OaiPmh::OaiPmhIdentifyService.call(system_id).payload
  end

end
