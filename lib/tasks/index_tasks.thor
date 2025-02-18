class IndexTasks < Thor

  namespace "index"

  desc "reindex", "Re-index models"

  def reindex
    begin
      Rails.logger.info "Starting reindex"
      Index::IndexAllService.call!
      Rails.logger.info "Finished reindex"
    rescue Exception => e
      Rails.logger.error e.message
    end
  end

end
