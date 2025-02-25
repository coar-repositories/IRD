class PlatformsController < ApplicationController
  before_action :set_platform, only: %i[ show edit update destroy systems]
  after_action :verify_authorized

  def systems
    authorize @platform
    @page_title = I18n.t(:repositories_running_on_platform, scope: :page_titles, platform: @platform.name)
    @pagy, @systems = pagy(@platform.systems.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json
      format.csv do
        @systems = @platform.systems.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /platforms or /platforms.json
  def index
    authorize :platform
    @page_title = t("activerecord.models.platform.other")
    respond_to do |format|
      format.html do
        @pagy, @platforms = pagy(Platform.order(:name), limit: 150)
        @record_count = @pagy.count
      end
      format.json do
        @pagy, @platforms = pagy(Platform.order(:name), limit: 150)
      end
      format.csv do
        @platforms = Platform.order(:name)
        send_data Platform.to_csv(@platforms), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /platforms/1 or /platforms/1.json
  def show
    authorize @platform
    @page_title = t("activerecord.models.platform.one") + ": " + @platform.name
    @stats = Stats::SystemSetStatsService.call(@platform.systems.publicly_viewable,"Repositories running on platform: #{@platform.name}").payload
  end

  # GET /platforms/new
  def new
    authorize :platform
    @platform = Platform.new
  end

  # GET /platforms/1/edit
  def edit
    authorize @platform
    @page_title = "Editing #{@platform.name}"
  end

  # POST /platforms or /platforms.json
  def create
    authorize :platform
    @page_title = "Create new #{Platform.model_name.human(count: 1)}"
    @platform = Platform.new(platform_params)

    respond_to do |format|
      if @platform.save
        format.html { redirect_to platform_url(@platform), notice: "Platform was successfully created." }
        format.json { render :show, status: :created, location: @platform }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /platforms/1 or /platforms/1.json
  def update
    authorize @platform
    respond_to do |format|
      if @platform.update(platform_params)
        format.html { redirect_to platform_url(@platform), notice: "Platform was successfully updated." }
        format.json { render :show, status: :ok, location: @platform }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @platform.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /platforms/1 or /platforms/1.json
  def destroy
    authorize @platform
    @platform.destroy
    respond_to do |format|
      format.html { redirect_to platforms_url, notice: "Platform was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_platform
    @platform = Platform.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def platform_params
    params.require(:platform).permit(:name, :url, :trusted, :oai_support, :oai_suffix, :match_order, matchers: [], generator_patterns: [])
  end
end
