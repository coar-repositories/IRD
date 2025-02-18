class CreateWebsiteThumbnailJob < ApplicationJob
  queue_as :default
  limits_concurrency to: eval(ENV.fetch("WEBSITE_THUMBNAIL_GENERATION_CONCURRENCY",2)), key: :create_website_thumbnail_job, duration: 2.minutes

  def perform(system_id, refresh_thumbnail)
    Website::ThumbnailGenerationService.call(system_id, refresh_thumbnail)
  end
end
