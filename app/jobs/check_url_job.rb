class CheckUrlJob < ApplicationJob
  queue_as :default

  def perform(system_id, parse_metadata_flag)
    Website::UrlCheckerService.call(system_id, parse_metadata_flag).payload
  end

end
