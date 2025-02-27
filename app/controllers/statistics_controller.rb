class StatisticsController < ApplicationController
  include CachedStatisticalDataSets
  after_action :verify_authorized

  def index
    authorize :statistics
    @page_title = t('statistics_and_graphs.statistics')
    @stats = Stats::SystemSetStatsService.call(System.publicly_viewable, "All Repositories").payload
    continent_data = []
    Country.translated_continents.each do |translated_continent|
      systems = System.joins(:country).where(countries: { continent: translated_continent[2] }).publicly_viewable
      continent_data << [translated_continent[0], systems.count]
    end
    @continent_graph_data = continent_data
  end

  def clear_cache
    authorize :statistics
    ["country_stats_#{I18n.locale}", "continent_stats_#{I18n.locale}", "platform_stats_#{I18n.locale}"].each { |key| Rails.cache.delete(key) }
    redirect_back fallback_location: root_path, notice: "Purged statistics caches"
  end

  def by_continent
    authorize :statistics
    @page_title = t('statistics_and_graphs.statistics_by_continent')
    @graph_and_table_data = get_continent_stats
    respond_to do |format|
      format.html
      format.csv do
        authorize :statistics, :download_csv?
        send_data Stats::SystemSetStatsCollectionService.call(@graph_and_table_data[:stats_set_collection]).payload, filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  def by_country
    authorize :statistics
    @page_title = t('statistics_and_graphs.statistics_by_country')
    @graph_and_table_data = get_country_stats
    respond_to do |format|
      format.html
      format.csv do
        authorize :statistics, :download_csv?
        send_data Stats::SystemSetStatsCollectionService.call(@graph_and_table_data[:stats_set_collection]).payload, filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  def by_platform
    authorize :statistics
    @page_title = t('statistics_and_graphs.statistics_by_software_platform')
    @graph_and_table_data = get_platform_stats
    respond_to do |format|
      format.html
      format.csv do
        authorize :statistics, :download_csv?
        send_data Stats::SystemSetStatsCollectionService.call(@graph_and_table_data[:stats_set_collection]).payload, filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end
end
