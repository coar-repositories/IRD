class CountriesController < ApplicationController
  require 'json'
  before_action :set_country, only: %i[ show systems]
  after_action :verify_authorized
  protect_from_forgery except: :geometries

  def systems
    authorize @country
    @page_title = t('page_titles.repositories_in_country', country: @country.name)
    @pagy, @systems = pagy(@country.systems.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize @country, :download_json?
      end
      format.csv do
        authorize @country, :download_csv?
        @systems = @country.systems.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
        # render plain: System.to_csv(@systems), content_type: 'text/csv'
      end
    end
  end

  def geometries
    authorize :country
    country_data = JSON.parse(File.read("#{__dir__}/../../db/json/countries_geometry.json"))
    country_data['features'].each do |feature|
      country = Country.find_by(id: feature['properties']['code'])
      if country
        feature['properties']['id'] = country.id
        feature['properties']['repositories'] = country.systems.count
      else
        Rails.logger.warn "Country not found: #{feature['properties']['name']}"
      end
    end
    render js: "var countriesData = " + country_data.to_json
  end

  def index
    authorize :country
    @page_title = t("activerecord.models.country.other")
    respond_to do |format|
      format.html do
        @pagy, @countries = pagy(Country.order(:name), limit: 300)
        @record_count = @pagy.count
      end
      format.json do
        authorize :country, :download_json?
        @pagy, @countries = pagy(Country.order(:name), limit: 300)
      end
      format.csv do
        authorize :country, :download_csv?
        @countries = Country.order(:name)
        send_data Country.to_csv(@countries), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /countries/1 or /countries/1.json
  def show
    authorize @country
    @stats = Stats::SystemSetStatsService.call(@country.systems.publicly_viewable, "Repositories in #{t("countries_list.#{@country.id}")}").payload
    @page_title = t("countries_list.#{@country.id}")
  end

  # PATCH/PUT /countries/1 or /countries/1.json

  # DELETE /countries/1 or /countries/1.json

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_country
    @country = Country.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  # def country_params
  #   params.require(:country).permit(:id, :name, :continent)
  # end
end
