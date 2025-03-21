class BrowserController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :browser
    @page_title = t('page_titles.repository_browser')
    search_terms = params[:search].presence || "*"
    conditions = {}
    # equivalent to scope :published, -> { where.not(record_status: :draft).where.not(record_status: :archived).where.not(system_status: :defunct) }
    # conditions = {record_status: :published }
    conditions[:country] = params[:country] if params[:country].present?
    conditions[:continent] = params[:continent] if params[:continent].present?
    conditions[:platform] = params[:platform] if params[:platform].present?
    conditions[:system_status] = params[:system_status] if params[:system_status].present?
    conditions[:oai_status] = params[:oai_status] if params[:oai_status].present?
    conditions[:subcategory] = params[:subcategory] if params[:subcategory].present?
    conditions[:primary_subject] = params[:primary_subject] if params[:primary_subject].present?
    conditions[:metadata_formats] = params[:metadata_formats] if params[:metadata_formats].present?
    conditions[:media_types] = params[:media_types] if params[:media_types].present?
    conditions[:record_status] = params[:record_status] if params[:record_status].present?
    conditions[:_not] = { record_status: [:draft,:archived] }

    page = params[:page] || 1
    per_page = params[:items] || Rails.application.config.ird[:catalogue_default_page_size].to_i

    facets = [:country,:continent,:platform,:system_status,:oai_status,:subcategory,:primary_subject, :metadata_formats, :media_types, :record_status]

    @unpaginated_systems = System.search(
      search_terms,
      where: conditions,
      aggs: facets,
      body_options: {
        track_total_hits: true
      },
      includes: [:network_checks,:repoids,:users, :metadata_formats]
    )

    @systems = System.search(
      search_terms,
      where: conditions,
      order: { name: :asc },
      aggs: facets,
      page: page,
      per_page: per_page,
      includes: [:network_checks,:repoids,:users, :metadata_formats]
      )

    @facets = @systems.aggs
    respond_to do |format|
      format.html do
        @pagy = Pagy.new_from_searchkick(@systems)
        @record_count = @pagy.count
      end
      format.json do
        authorize :browser, :download_json?
        @pagy = Pagy.new_from_searchkick(@systems)
      end
      format.csv do
        authorize :browser, :download_csv?
        send_data System.to_csv(@unpaginated_systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end
end
