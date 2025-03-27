require "ostruct"

class SystemsController < ApplicationController
  before_action :set_system, only: %i[ show edit update destroy authorise_user network_check check_url check_oai_pmh_identify check_oai_pmh_formats check_oai_pmh_combined get_thumbnail remove_thumbnail label add_repo_id process_as_duplicate set_record_verified set_record_archived set_record_draft auto_curate set_record_awaiting_review set_record_under_review]
  after_action :verify_authorized

  def suggest_new_system
    authorize :system
    puts "params: #{params.inspect}"
    service_result = Ingest::SuggestSystemService.call(params, current_user)
    if service_result.success?
      redirect_back fallback_location: root_path, flash: { message: "A new repository has been added to IRD. It will be processed shortly." }
    else
      redirect_back fallback_location: root_path, flash: { error: "#{service_result.error.message}" }
    end
  end

  def search
    authorize :system
    @page_title = "Systems Search"
    search_terms = params[:search].presence || "*"
    page = params[:page] || 1
    per_page = params[:items] || Rails.application.config.ird[:catalogue_default_page_size].to_i
    @search_result = System.search(
      search_terms,
      page: page,
      per_page: per_page,
      body_options: {
        track_total_hits: true
      }
    )
    @systems = @search_result.order(:name)
    respond_to do |format|
      format.html do
        @pagy = Pagy.new_from_searchkick(@search_result)
        @systems = @search_result.order(:name)
        @record_count = @pagy.count
      end
      format.json do
        authorize :system, :download_json?
        @pagy = Pagy.new_from_searchkick(@search_result)
        @systems = @search_result.order(:name)
      end
      format.csv do
        authorize :system, :download_csv?
        @systems = @search_result.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: "text/csv"
      end
    end
  end

  def process_as_duplicate
    authorize @system
    begin
      target_system = System.includes(:network_checks, :repoids, :users).find(params[:target_system_id])
      target_system.update_from_duplicate_system(@system)
      target_system.save!
      @system.label_list.add "duplicate"
      @system.record_status = :archived
      @system.save!
      redirect_back fallback_location: root_path, notice: "Processed as duplicate of #{params[:target_system_id]}"
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to process as duplicate: #{e.message}" }
    end
  end

  # def mark_reviewed
  #   authorize @system
  #   begin
  #     @system.mark_reviewed!
  #     @system.save!
  #     redirect_back fallback_location: root_path, notice: "Repository marked as reviewed."
  #   rescue Exception => e
  #     redirect_back fallback_location: root_path, flash: { error: "Unable to mark repository as reviewed: #{e.message}" }
  #   end
  # end

  def set_record_verified
    authorize @system
    begin
      @system.verify!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record verified."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to verify repository record: #{e.message}" }
    end
  end

  def set_record_archived
    authorize @system
    begin
      if params[:archive_label]
        @system.label_list.add params[:archive_label].to_s
      end
      @system.archive!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record archived."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to archive repository record: #{e.message}" }
    end
  end

  def set_record_draft
    authorize @system
    begin
      @system.draft!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record made draft."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to make repository record draft: #{e.message}" }
    end
  end

  def set_record_awaiting_review
    authorize @system
    begin
      @system.awaiting_review!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record set to 'awaiting review'."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to set repository record to 'awaiting review': #{e.message}" }
    end
  end

  def set_record_under_review
    authorize @system
    begin
      @system.review!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record set to 'under review'."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to set repository record to 'under review': #{e.message}" }
    end
  end

  def add_repo_id
    authorize @system
    begin
      @system.add_repo_id(params[:repo_id_scheme], params[:repo_id_value])
      @system.save!
      redirect_to system_url(@system), notice: "Added repository identifier"
    rescue Exception => e
      redirect_to system_url(@system), flash: { error: "Unable to add repository identifier: #{e.message}" }
    end
  end

  def authorise_user
    authorize @system
    begin
      user = User.find_or_create_by!(email: params[:email]) do |u|
        u.last_name = params[:last_name]
        u.fore_name = params[:fore_name]
      end
      @system.users << user
      redirect_to system_url(@system), notice: "User is now authorised to curate this repository."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to system_url(@system), flash: { error: "User was not created; #{e.message}" }
    rescue ActiveRecord::RecordNotUnique
      redirect_to system_url(@system), flash: { alert: "User is already authorised to curate this repository." }
    end
  end

  def network_check
    authorize @system
    CheckUrlJob.perform_later(@system.id, true)
    CheckOaiPmhIdentifyJob.perform_later(@system.id)
    # CreateWebsiteThumbnailJob.perform_later(@system.id, true)
    CheckOaiPmhFormatsJob.perform_later(@system.id)
    redirect_to system_url(@system), notice: "Network Jobs started in background."
  end

  def auto_curate
    authorize @system
    service_result = Curation::SystemCuratorService.call(@system)
    if service_result.success?
      @system = service_result.payload
      @system.save!
      redirect_back fallback_location: root_path, notice: "Auto-curate completed."
    else
      redirect_back fallback_location: root_path, flash: { error: "Auto-curate failed: #{service_result.error.message}" }
    end
  end

  def check_url
    authorize @system
    service_result = Website::UrlCheckerService.call(@system.id, true)
    if service_result.success?
      @system = service_result.payload
      if @system.system_status_online?
        redirect_back fallback_location: root_path, notice: "URL check completed successfully - system is online"
      else
        redirect_back fallback_location: root_path, flash: { error: "URL check completed: System status is #{@system.system_status}" }
      end
    else
      redirect_back fallback_location: root_path, flash: { error: "URL check failed: #{service_result.error.message}" }
    end
  end

  def check_oai_pmh_combined
    authorize @system
    service_result = OaiPmh::OaiPmhIdentifyService.call(@system.id)
    if service_result.success?
      @system = service_result.payload
      service_result2 = OaiPmh::OaiPmhMetadataFormatsService.call(@system.id)
      if service_result2.success?
        @system = service_result2.payload
        Curation::SystemMetadataFormatAssociationService.call(@system)
        if @system.oai_status_online?
          redirect_back fallback_location: root_path, notice: "OAI-PMH check completed successfully - OAI-PMH is functioning correctly"
        else
          redirect_back fallback_location: root_path, flash: { error: "OAI-PMH check completed: OAI-PMH status is #{@system.oai_status}" }
        end
      end
    else
      redirect_back fallback_location: root_path, flash: { error: "OAI-PMH check failed: #{service_result.error.message}" }
    end
  end

  def check_oai_pmh_identify
    authorize @system
    service_result = OaiPmh::OaiPmhIdentifyService.call(@system.id)
    if service_result.success?
      @system = service_result.payload
      if @system.oai_status_online?
        redirect_back fallback_location: root_path, notice: "OAI-PMH Identify check completed successfully - OAI-PMH is functioning correctly"
      else
        redirect_back fallback_location: root_path, flash: { error: "OAI-PMH Identify check completed: OAI-PMH status is #{@system.oai_status}" }
      end
    else
      redirect_back fallback_location: root_path, flash: { error: "OAI-PMH Identify failed: #{service_result.error.message}" }
    end
  end

  def check_oai_pmh_formats
    authorize @system
    service_result = OaiPmh::OaiPmhMetadataFormatsService.call(@system.id)
    if service_result.success?
      @system = service_result.payload
      Curation::SystemMetadataFormatAssociationService.call(@system)
      if @system.oai_status_online?
        redirect_back fallback_location: root_path, notice: "OAI-PMH Metadata Formats check completed successfully - OAI-PMH is functioning correctly"
      else
        redirect_back fallback_location: root_path, flash: { error: "OAI-PMH Metadata Formats  check completed: OAI-PMH status is #{@system.oai_status}" }
      end
    else
      redirect_back fallback_location: root_path, flash: { error: "OAI-PMH Metadata Formats check failed: #{service_result.error.message}" }
    end
  end

  def get_thumbnail
    authorize @system
    CreateWebsiteThumbnailJob.perform_later(@system.id, true)
    redirect_back fallback_location: root_path, notice: "Generating thumbnail as an asynchronous background process - check back in a few minutes"
  end

  def remove_thumbnail
    authorize @system
    @system.thumbnail.purge
    # redirect_to system_url(@system), notice: "Website thumbnail retrieved."
    redirect_back fallback_location: root_path, notice: "Website thumbnail removed."
  end

  def label
    authorize @system
    begin
      label = params[:label_to_process]
      if !params[:add_or_remove] || params[:add_or_remove].to_sym == :add
        @system.label_list.add label
      elsif params[:add_or_remove].to_sym == :remove
        @system.label_list.remove label
      end
      @system.save!
      redirect_back fallback_location: root_path, notice: "Changed system label " + t("labels.#{label}")
    rescue StandardError => e
      Rails.logger.error "Unable to label system with " + t("labels.#{label}") + ": #{e.message}"
      redirect_back fallback_location: root_path, notice: "Unable to label system with " + t("labels.#{label}")
    end
  end

  # GET /systems or /systems.json
  def index
    authorize :system
    @page_title = t("activerecord.models.system.other")
    @pagy, @systems = pagy(System.all.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize :system, :download_json?
      end
      format.csv do
        authorize :system, :download_csv?
        @systems = System.all.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: "text/csv"
      end
    end
  end

  # GET /systems/1 or /systems/1.json
  def show
    authorize @system
    @page_title = @system.name
  end

  # GET /systems/new
  def new
    authorize :system
    @system = System.new
  end

  # GET /systems/1/edit
  def edit
    authorize @system
    @page_title = "Editing #{self.controller_name.humanize}: #{@system.name}"
    @system.repoids.build
  end

  # POST /systems or /systems.json
  def create
    authorize :system
    @system = System.new(system_params)
    respond_to do |format|
      if @system.save
        format.html { redirect_to system_url(@system), notice: "System was successfully created." }
        format.json { render :show, status: :created, location: @system }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @system.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /systems/1 or /systems/1.json
  def update
    authorize @system
    respond_to do |format|
      if @system.update(system_params)
        format.html { redirect_to system_url(@system), notice: "System was successfully updated." }
        format.json { render :show, status: :ok, location: @system }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @system.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /systems/1 or /systems/1.json
  def destroy
    authorize @system
    @system.destroy

    respond_to do |format|
      format.html { redirect_to systems_url, notice: "System was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_system
    @system = System.includes(:network_checks, :repoids, :users).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def system_params
    params.require(:system).permit(:name, :short_name, :url, :description, :contact, :subcategory, :system_status, :oai_status, :platform_id, :country_id, :platform_version, :record_status, :record_source, :primary_subject, :owner_id, :rp_id, :oai_base_url, :system_category, :tag_list, :archive_label, :label_list => [], :media_types => [], :aliases => [], :user_ids => [], :repoids_attributes => [[:id, :identifier_scheme, :identifier_value, :_destroy]])
  end

  # def suggested_new_system_params
  #   params.require(:system).permit(:name, :url, :country_id, :record_source, :owner_id, :system_category)
  # end
end
