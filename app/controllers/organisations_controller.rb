class OrganisationsController < ApplicationController
  before_action :set_organisation, only: %i[ show edit update destroy ownerships responsibilities add_user_as_agent make_rp make_rp_for_country remove_rp_status]
  # check_url check_oai_pmh_identify check_oai_pmh_formats get_website_thumbnail
  after_action :verify_authorized

  def search
    authorize :organisation
    @page_title = 'Organisation Search'
    search_terms = params[:search].presence || "*"
    page = params[:page] || 1
    per_page = params[:items] || Rails.application.config.ird[:catalogue_default_page_size].to_i
    @search_result = Organisation.search(
      search_terms,
      page: page,
      per_page: per_page,
      body_options: {
        track_total_hits: true
      }
    )
    @organisations = @search_result.order(:name)
    respond_to do |format|
      format.html do
        @pagy = Pagy.new_from_searchkick(@search_result)
        @organisations = @search_result.order(:name)
        @record_count = @pagy.count
      end
      format.json do
        authorize :organisation, :download_json?
        @pagy = Pagy.new_from_searchkick(@search_result)
        @organisations = @search_result.order(:name)
      end
      format.csv do
        authorize :organisation, :download_csv?
        @organisations = @search_result.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  def autocomplete
    authorize :organisation
    @organisations = Organisation.search(params[:term])
    render json: @organisations.map { |o| { label: o.name, value: o.id } }
  end

  def make_rp
    authorize @organisation
    @organisation.make_rp!
    @organisation.save!
    redirect_back fallback_location: root_path, notice: "Organisation was successfully made a Responsible Party."
  end

  def remove_rp_status
    authorize @organisation
    service_result = Rp::RemoveRpStatusService.call(@organisation)
    # redirect_back fallback_location: root_path, notice: "#{service_result.inspect}"
    if service_result.success?
      @organisation = service_result.payload
      @organisation.save!
      redirect_back fallback_location: root_path, notice: "Organisation was successfully removed from the list of Responsible Parties"
    else
      redirect_back fallback_location: root_path, error: "#{service_result.error.message}"
    end
  end

  def make_rp_for_country
    authorize @organisation
    if @organisation.country.present?
      @organisation.make_rp!
      @organisation.save!
      ActiveJob.perform_all_later(@organisation.country.systems.map { |system| AllocateRpByCountryJob.new(system.id) })
      redirect_back fallback_location: root_path, notice: "Making this organisation Responsible Organisation for repositories in #{@organisation.country.name}."
    else
      redirect_back fallback_location: root_path, alert: "This organisation does not have a country."
    end
  end

  def add_user_as_agent
    authorize @organisation
    begin
      user = User.find_or_create_by!(email: params[:email]) do |u|
        u.last_name = params[:last_name]
        u.fore_name = params[:fore_name]
      end
      # user = User.find_or_create_by!(email: params[:email])
      @organisation.users << user
      redirect_to organisation_url(@organisation), notice: "User was successfully created and made an agent for this organisation."
    rescue ActiveRecord::RecordInvalid => e
      # redirect_to organisation_url(@organisation), flash: { error: "User was not created; #{e.message}" }
      redirect_back fallback_location: root_path, flash: { error: "User was not created; #{e.message}" }
    rescue ActiveRecord::RecordNotUnique
      redirect_to organisation_url(@organisation), flash: { alert: "User is already an agent for this organisation." }
    end
  end

  def ownerships
    authorize @organisation
    @page_title = "Repositories owned by #{@organisation.name}"
    @pagy, @systems = pagy(@organisation.ownerships.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize @organisation, :download_json?
      end
      format.csv do
        authorize @organisation, :download_csv?
        @systems = @organisation.ownerships.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  def responsibilities
    authorize @organisation
    @page_title = "Repositories curated by #{@organisation.name}"
    @pagy, @systems = pagy(@organisation.responsibilities.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize @organisation, :download_json?
      end
      format.csv do
        authorize @organisation, :download_csv?
        @systems = @organisation.responsibilities.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  def responsible_parties
    authorize :organisation
    @page_title = "Responsible Parties"
    @pagy, @organisations = pagy(Organisation.rps.order('lower(name)'), limit: 100)
    # @organisations = Organisation.responsible_parties.order('lower(name)')
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize :organisation, :download_json?
      end
      format.csv do
        authorize :organisation, :download_csv?
        @organisations = Organisation.rps.order('lower(name)')
        send_data Organisation.to_csv(@organisations), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /organisations or /organisations.json
  def index
    authorize :organisation
    @page_title = t("activerecord.models.organisation.other")
    @pagy, @organisations = pagy(Organisation.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize :organisation, :download_json?
      end
      # don't allow csv download - massive dataset!
    end
  end

  # GET /organisations/1 or /organisations/1.json
  def show
    authorize @organisation
    @page_title = "#{Organisation.model_name.human}: #{@organisation.name}"
  end

  # GET /organisations/new
  def new
    authorize :organisation
    @organisation = Organisation.new
    @page_title = "Create new #{self.controller_name.humanize}"
  end

  # GET /organisations/1/edit
  def edit
    authorize :organisation
    @page_title = "Edit #{self.controller_name.humanize}: " + @organisation.name
  end

  # POST /organisations or /organisations.json
  def create
    authorize :organisation
    @organisation = Organisation.new(organisation_params)

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to organisation_url(@organisation), notice: "Organisation was successfully created." }
        format.json { render :show, status: :created, location: @organisation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organisations/1 or /organisations/1.json
  def update
    authorize @organisation
    respond_to do |format|
      if @organisation.update(organisation_params)
        format.html { redirect_to organisation_url(@organisation), notice: "Organisation was successfully updated." }
        format.json { render :show, status: :ok, location: @organisation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1 or /organisations/1.json
  def destroy
    authorize @organisation
    @organisation.destroy!

    respond_to do |format|
      format.html { redirect_to organisations_url, notice: "Organisation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organisation
    @organisation = Organisation.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def organisation_params
    params.require(:organisation).permit(:name, :short_name, :ror, :location, :latitude, :longitude, :country_id, :website, :rp, :aliases => [], :user_ids => [])
  end
end
