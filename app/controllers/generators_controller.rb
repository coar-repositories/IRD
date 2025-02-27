class GeneratorsController < ApplicationController
  before_action :set_generator, only: %i[ show edit update destroy systems]
  after_action :verify_authorized

  def systems
    authorize @generator
    @page_title = "Repositories running on #{@generator.name}"
    @pagy, @systems = pagy(@generator.systems.publicly_viewable.order(:name))
    respond_to do |format|
      format.html do
        @record_count = @pagy.count
      end
      format.json do
        authorize @generator, :download_json?
      end
      format.csv do
        authorize @generator, :download_csv?
        @systems = @generator.systems.publicly_viewable.order(:name)
        send_data System.to_csv(@systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /generators or /generators.json
  def index
    authorize :generator
    @page_title = t("activerecord.models.generator.other")
    @pagy, @generators = pagy(Generator.order(:name), limit: 500)
    @record_count = @pagy.count
    respond_to do |format|
      format.html
      format.json do
        authorize :generator, :download_json?
      end
    end
  end

  # GET /generators/1 or /generators/1.json
  def show
    authorize @generator
    @page_title = "#{self.controller_name.humanize}: #{@generator.name}"
  end

  # GET /generators/new
  def new
    authorize :generator
    @generator = Generator.new
  end

  # GET /generators/1/edit
  def edit
    authorize :generator
  end

  # POST /generators or /generators.json
  def create
    authorize :generator
    @generator = Generator.new(generator_params)

    respond_to do |format|
      if @generator.save
        format.html { redirect_to generator_url(@generator), notice: "Generator was successfully created." }
        format.json { render :show, status: :created, location: @generator }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /generators/1 or /generators/1.json
  def update
    authorize @generator
    respond_to do |format|
      if @generator.update(generator_params)
        format.html { redirect_to generator_url(@generator), notice: "Generator was successfully updated." }
        format.json { render :show, status: :ok, location: @generator }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @generator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /generators/1 or /generators/1.json
  def destroy
    authorize @generator
    @generator.destroy

    respond_to do |format|
      format.html { redirect_to generators_url, notice: "Generator was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_generator
    @generator = Generator.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def generator_params
    params.require(:generator).permit(:name, :platform_id, :version)
  end
end
