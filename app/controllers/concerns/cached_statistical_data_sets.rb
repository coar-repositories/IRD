# frozen_string_literal: true

module CachedStatisticalDataSets
  extend ActiveSupport::Concern

  def get_country_stats
    Rails.cache.fetch("country_stats_#{I18n.locale}", expires_in: 12.hours) do
      graph_and_table_data = { stats_set_collection: [], graph_data: [] }
      country_data = {}
      Country.order(:name).each do |country|
        systems = country.systems.publicly_viewable
        country_name = t("countries_list.#{country.id}")
        graph_and_table_data[:stats_set_collection] << Stats::SystemSetStatsService.call(systems, country_name).payload
        if systems.count > 30
          country_data[country_name] = {}
          country_data[country_name][:total] = systems.count
          country_data[country_name][:responding] = systems.oai_status_online.count
          country_data[country_name][:not_responding] = (systems.oai_status_offline.count + systems.oai_status_not_enabled.count + systems.oai_status_unknown.count)
          country_data[country_name][:not_supported] = (systems.oai_status_unsupported.count)
        end
      end
      country_data = country_data.sort_by { |_k, v| -v[:total] }[0..19].to_h
      oai_responding_series = { name: System.translated_oai_status(:online), color: 'green', data: [] }
      oai_not_responding_series = { name: System.translated_oai_status(:offline), color: 'orange', data: [] }
      oai_not_supported_series = { name: System.translated_oai_status(:unsupported), color: 'red', data: [] }
      country_data.each_pair do |k, v|
        oai_responding_series[:data] << [k, v[:responding]]
        oai_not_responding_series[:data] << [k, v[:not_responding]]
        oai_not_supported_series[:data] << [k, v[:not_supported]]
      end
      graph_and_table_data[:graph_data] = [oai_responding_series, oai_not_responding_series, oai_not_supported_series]
      graph_and_table_data
    end
  end

  def get_continent_stats
    Rails.cache.fetch("continent_stats_#{I18n.locale}", expires_in: 12.hours) do
      graph_and_table_data = { stats_set_collection: [], graph_data: [] }
      continent_data = {}
      Country.translated_continents.each do |translated_continent|
        systems = System.joins(:country).where(countries: { continent: translated_continent[2] }).publicly_viewable
        graph_and_table_data[:stats_set_collection] << Stats::SystemSetStatsService.call(systems, translated_continent[0]).payload
        continent_data[translated_continent[0]] = {}
        continent_data[translated_continent[0]][:total] = systems.count
        continent_data[translated_continent[0]][:responding] = systems.oai_status_online.count
        continent_data[translated_continent[0]][:not_responding] = (systems.oai_status_offline.count + systems.oai_status_not_enabled.count + systems.oai_status_unknown.count)
        continent_data[translated_continent[0]][:not_supported] = (systems.oai_status_unsupported.count)
      end
      continent_data = continent_data.sort_by { |_k, v| -v[:total] }.to_h
      oai_responding_series = { name: System.translated_oai_status(:online), color: 'green', data: [] }
      oai_not_responding_series = { name: System.translated_oai_status(:offline), color: 'orange', data: [] }
      oai_not_supported_series = { name: System.translated_oai_status(:unsupported), color: 'red', data: [] }
      continent_data.each_pair do |k, v|
        oai_responding_series[:data] << [k, v[:responding]]
        oai_not_responding_series[:data] << [k, v[:not_responding]]
        oai_not_supported_series[:data] << [k, v[:not_supported]]
      end
      graph_and_table_data[:graph_data] = [oai_responding_series, oai_not_responding_series, oai_not_supported_series]
      graph_and_table_data
    end
  end

  def get_platform_stats
    Rails.cache.fetch("platform_stats_#{I18n.locale}", expires_in: 12.hours) do
      graph_and_table_data = { stats_set_collection: [], graph_data: [] }
      platform_data = {}
      Platform.order(:name).each do |platform|
        systems = platform.systems.publicly_viewable
        graph_and_table_data[:stats_set_collection] << Stats::SystemSetStatsService.call(systems, platform.name).payload
        if systems.count > 10
          platform_data[platform.name] = {}
          platform_data[platform.name][:total] = systems.count
          platform_data[platform.name][:responding] = systems.oai_status_online.count
          platform_data[platform.name][:not_responding] = (systems.oai_status_offline.count + systems.oai_status_not_enabled.count + systems.oai_status_unknown.count)
          platform_data[platform.name][:not_supported] = (systems.oai_status_unsupported.count)
        end
      end
      platform_data = platform_data.sort_by { |_k, v| -v[:total] }.to_h
      oai_responding_series = { name: System.translated_oai_status(:online), color: 'green', data: [] }
      oai_not_responding_series = { name: System.translated_oai_status(:offline), color: 'orange', data: [] }
      oai_not_supported_series = { name: System.translated_oai_status(:unsupported), color: 'red', data: [] }
      platform_data.each_pair do |k, v|
        oai_responding_series[:data] << [k, v[:responding]]
        oai_not_responding_series[:data] << [k, v[:not_responding]]
        oai_not_supported_series[:data] << [k, v[:not_supported]]
      end
      graph_and_table_data[:graph_data] = [oai_responding_series, oai_not_responding_series, oai_not_supported_series]
      graph_and_table_data
    end
  end
end
