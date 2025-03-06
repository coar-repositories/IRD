class MetadataFormatsController < ApplicationController
  before_action :set_metadata_format, only: %i[ show edit update destroy systems]
  after_action :verify_authorized


  def systems
    authorize @metadata_format
    @page_title = I18n.t(:repositories_supporting_metadata_format, scope: :page_titles, metadata_format: @metadata_format.name)
    @pagy, @systems = pagy(@metadata_format.systems.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize @metadata_format, :download_json?
      end
      format.csv do
        authorize @metadata_format, :download_csv?
        @systems = @metadata_format.systems.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /metadata_formats or /metadata_formats.json
  def index
    authorize :metadata_format
    @page_title = t("activerecord.models.metadata_format.other")
    # @metadata_formats = MetadataFormat.all
    respond_to do |format|
      format.html do
        @pagy, @metadata_formats = pagy(MetadataFormat.order(:name), limit: 150)
        @record_count = @pagy.count
      end
      format.json do
        authorize :metadata_format, :download_json?
        @pagy, @metadata_formats = pagy(MetadataFormat.order(:name), limit: 150)
      end
      format.csv do
        authorize :metadata_format, :download_csv?
        @metadata_formats = MetadataFormat.order(:name)
        send_data MetadataFormat.to_csv(@metadata_formats), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /metadata_formats/1 or /metadata_formats/1.json
  def show
    authorize @metadata_format
    @page_title = t("activerecord.models.metadata_format.one") + ": " + @metadata_format.name
  end

  # GET /metadata_formats/new
  def new
    authorize :metadata_format
    @metadata_format = MetadataFormat.new
    @page_title = "New " + t("activerecord.models.metadata_format.one")
  end

  # GET /metadata_formats/1/edit
  def edit
    authorize @metadata_format
    @page_title = "Editing #{@metadata_format.name}"
  end

  # POST /metadata_formats or /metadata_formats.json
  def create
    authorize :metadata_format
    @metadata_format = MetadataFormat.new(metadata_format_params)

    respond_to do |format|
      if @metadata_format.save
        format.html { redirect_to @metadata_format, notice: "Metadata format was successfully created." }
        format.json { render :show, status: :created, location: @metadata_format }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @metadata_format.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /metadata_formats/1 or /metadata_formats/1.json
  def update
    authorize @metadata_format
    respond_to do |format|
      if @metadata_format.update(metadata_format_params)
        format.html { redirect_to @metadata_format, notice: "Metadata format was successfully updated." }
        format.json { render :show, status: :ok, location: @metadata_format }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @metadata_format.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /metadata_formats/1 or /metadata_formats/1.json
  def destroy
    authorize @metadata_format
    @metadata_format.destroy!

    respond_to do |format|
      format.html { redirect_to metadata_formats_path, status: :see_other, notice: "Metadata format was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_metadata_format
      @metadata_format = MetadataFormat.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def metadata_format_params
      params.expect(metadata_format: [ :name, :canonical_schema, :match_order,matchers: [] ])
    end
end
