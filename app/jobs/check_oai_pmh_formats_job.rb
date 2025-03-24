class CheckOaiPmhFormatsJob < ApplicationJob
  queue_as :default

  def perform(system_id)
    system = OaiPmh::OaiPmhMetadataFormatsService.call(system_id).payload
    Curation::SystemMetadataFormatAssociationService.call(system)
  end

end
