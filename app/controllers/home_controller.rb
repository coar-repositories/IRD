class HomeController < ApplicationController
  def index
    @page_title = t('page_titles.welcome')
    @stats = Stats::SystemSetStatsService.call(System.all, "All Repositories").payload
    continent_data = []
    Country.translated_continents.each do |translated_continent|
      # unless ['global', 'antarctica'].include? translated_continent[1]
      systems = System.joins(:country).where(countries: { continent: translated_continent[2] })
      continent_data << ["#{translated_continent[0]} (#{systems.count})", systems.count]
      # end
    end
    @continent_graph_data = continent_data
  end

end