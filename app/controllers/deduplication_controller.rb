class DeduplicationController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :deduplication
    @page_title = "De-duplication"
    @potential_duplicates = Normalid.select(:url).group(:url).having("count(*) > 1")
  end

  def deduplicate
    authorize :deduplication
    DeduplicationJob.perform_later
    redirect_back fallback_location: root_path, notice: "Deduplicated systems"
  end

end
