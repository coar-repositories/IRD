class HomeController < ApplicationController
  def index
    @page_title = t('page_titles.welcome')
    @stats = Stats::SystemSetStatsService.call(System.publicly_viewable, "All Repositories").payload
    continent_data = []
    Country.translated_continents.each do |translated_continent|
      # unless ['global', 'antarctica'].include? translated_continent[1]
      systems = System.joins(:country).where(countries: { continent: translated_continent[2] }).publicly_viewable
      continent_data << [translated_continent[0], systems.count]
      # end
    end
    @continent_graph_data = continent_data
  end

end