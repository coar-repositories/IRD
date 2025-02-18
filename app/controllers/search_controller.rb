class SearchController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :search
    @page_title = t('page_titles.search')
    search_terms = params[:q].presence || "*"
    page = params[:page] || 1
    per_page = params[:items] || Rails.application.config.ird[:catalogue_default_page_size].to_i
    @search_result = Searchkick.search(
      search_terms,
      models: [System, Organisation],
      page: page,
      per_page: per_page,
    )
    @pagy = Pagy.new_from_searchkick(@search_result)
    respond_to do |format|
      format.html
    end
  end
end
