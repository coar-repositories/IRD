class CheckUrlJob < ApplicationJob
  queue_as :default

  def perform(system_id, parse_metadata_flag)
    system = Website::UrlCheckerService.call(system_id, parse_metadata_flag).payload
    system.save!
  end

end
