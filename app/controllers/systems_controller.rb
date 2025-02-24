require "ostruct"

class SystemsController < ApplicationController
  before_action :set_system, only: %i[ show edit update destroy authorise_user network_check check_url check_oai_pmh_identify check_oai_pmh_formats get_thumbnail remove_thumbnail annotate flag_as_archived add_repo_id process_as_duplicate mark_reviewed publish archive make_draft auto_curate change_record_status_to_under_review]
  after_action :verify_authorized

  def suggest_new_system
    authorize :system
    service_result = Ingest::SuggestSystemService.call(params)
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
        @pagy = Pagy.new_from_searchkick(@search_result)
        @systems = @search_result.order(:name)
      end
      format.csv do
        @systems = @search_result.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: "text/csv"
      end
    end
  end

  def process_as_duplicate
    authorize @system
    begin
      target_system = System.includes(:network_checks, :repoids, :media, :annotations, :users).find(params[:target_system_id])
      target_system.update_from_duplicate_system(@system)
      target_system.save!
      @system.add_annotation(Annotation.find("duplicate"))
      @system.record_status = :archived
      @system.save!
      redirect_back fallback_location: root_path, notice: "Processed as duplicate of #{params[:target_system_id]}"
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to process as duplicate: #{e.message}" }
    end
  end

  def mark_reviewed
    authorize @system
    begin
      @system.mark_reviewed!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository marked as reviewed."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to mark repository as reviewed: #{e.message}" }
    end
  end

  def publish
    authorize @system
    begin
      @system.publish!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record published."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to publish repository record: #{e.message}" }
    end
  end

  def archive
    authorize @system
    begin
      @system.archive!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record archived."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to archive repository record: #{e.message}" }
    end
  end

  def make_draft
    authorize @system
    begin
      @system.make_draft!
      @system.save!
      redirect_back fallback_location: root_path, notice: "Repository record made draft."
    rescue Exception => e
      redirect_back fallback_location: root_path, flash: { error: "Unable to make repository record draft: #{e.message}" }
    end
  end

  def change_record_status_to_under_review
    authorize @system
    begin
      @system.change_record_status_to_under_review!
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

  # def authorise_existing_user
  #   authorize @system
  #   begin
  #     @system.users << User.find(params[:user_id])
  #     redirect_to system_url(@system), notice: "User was successfully authorised."
  #   rescue ActiveRecord::RecordNotFound
  #     redirect_to system_url(@system), flash: { error: "User not found. Please click 'Add a new user and authorise them' instead." }
  #   rescue ActiveRecord::RecordNotUnique
  #     redirect_to system_url(@system), flash: { alert: "User is already authorised to curate this repository." }
  #   end
  # end

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
    AutoCurateJob.perform_now(@system.id)
    redirect_back fallback_location: root_path, notice: "Auto-curate completed."
  end

  def check_url
    authorize @system
    CheckUrlJob.perform_now(@system.id, true)
    # redirect_to system_url(@system), notice: "URL check completed."
    redirect_back fallback_location: root_path, notice: "URL check completed."
  end

  def check_oai_pmh_identify
    authorize @system
    CheckOaiPmhIdentifyJob.perform_now(@system.id)
    # redirect_to system_url(@system), notice: "OAI-PMH Identify completed."
    redirect_back fallback_location: root_path, notice: "OAI-PMH Identify completed."
  end

  def check_oai_pmh_formats
    authorize @system
    CheckOaiPmhFormatsJob.perform_now(@system.id)
    # redirect_to system_url(@system), notice: "OAI-PMH Metadata formats checked."
    redirect_back fallback_location: root_path, notice: "OAI-PMH Metadata formats checked."
  end

  def get_thumbnail
    authorize @system
    CreateWebsiteThumbnailJob.perform_now(@system.id, true)
    # redirect_to system_url(@system), notice: "Website thumbnail retrieved."
    redirect_back fallback_location: root_path, notice: "Website thumbnail retrieved."
  end

  def remove_thumbnail
    authorize @system
    @system.thumbnail.purge
    # redirect_to system_url(@system), notice: "Website thumbnail retrieved."
    redirect_back fallback_location: root_path, notice: "Website thumbnail removed."
  end

  def annotate
    authorize @system
    begin
      annotation = Annotation.find(params[:annotation])
      if !params[:add_or_remove] || params[:add_or_remove].to_sym == :add
        @system.add_annotation annotation
      elsif params[:add_or_remove].to_sym == :remove
        @system.remove_annotation annotation
      end
      @system.save!
      redirect_back fallback_location: root_path, notice: "Changed system annotation (#{annotation.name})."
    rescue ActiveRecord::RecordNotUnique
      redirect_back fallback_location: root_path, notice: "System is already annotated with '#{annotation.name}'"
    rescue StandardError => e
      Rails.logger.error "Unable to annotate system with '#{annotation.name}': #{e.message}"
      redirect_back fallback_location: root_path, notice: "Unable to annotate system with '#{annotation.name}'"
    end
  end

  def flag_as_archived
    authorize @system
    @system.record_status = :archived
    @system.save!
    redirect_back fallback_location: root_path, notice: "Record archived."
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
      format.json
      format.csv do
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
    @system = System.includes(:network_checks, :repoids, :media, :annotations, :users).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def system_params
    params.require(:system).permit(:name, :short_name, :url, :description, :contact, :subcategory, :system_status, :oai_status, :platform_id, :country_id, :platform_version, :record_status, :record_source, :primary_subject, :owner_id, :rp_id, :oai_base_url, :system_category, :tag_list, :aliases => [], :user_ids => [], :annotation_ids => [], :medium_ids => [], :repoids_attributes => [[:id, :identifier_scheme, :identifier_value, :_destroy]])
  end

  # def suggested_new_system_params
  #   params.require(:system).permit(:name, :url, :country_id, :record_source, :owner_id, :system_category)
  # end
end
