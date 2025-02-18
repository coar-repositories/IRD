class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy generate_api_key revoke_access restore_access]
  after_action :verify_authorized
  def dashboard
    authorize :user
    @user = current_user
    unless @user.verified
      @user.verified = true
      @user.save!
    end
    redirect_to user_path(@user)
  end

  def generate_api_key
    authorize @user
    @new_api_key = @user.generate_and_return_api_key
    redirect_back fallback_location: root_path, flash: { message: "New API Key: #{@new_api_key}" }
  end

  def revoke_access
    authorize @user
    @user.revoke_access!
    redirect_back fallback_location: root_path, flash: { message: "Revoked access for user with email: #{@user.email}" }
  end

  def restore_access
    authorize @user
    @user.restore_access!
    redirect_back fallback_location: root_path, flash: { message: "Restored access for user with email: #{@user.email}" }
  end

  # GET /users or /users.json
  def index
    authorize :user
    @page_title = t("activerecord.models.user.other")
    respond_to do |format|
      format.html do
        @pagy, @users = pagy(User.order(:last_name))
        @record_count = @pagy.count
      end
      format.json do
        @pagy, @users = pagy(User.order(:last_name))
      end
      format.csv do
        @users = User.order(:last_name)
        send_data User.to_csv(@users), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  # GET /users/1 or /users/1.json
  def show
    authorize @user
    @page_title = t('page_titles.dashboard_for', name: @user.display_name)
  end

  # GET /users/new
  def new
    @page_title = "New #{self.controller_name.singularize.humanize}"
    authorize :user
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @page_title = "Edit #{self.controller_name.singularize.humanize}"
    authorize @user
  end

  # POST /users or /users.json
  def create
    authorize :user
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    authorize @user
    respond_to do |format|
      if @user.update(permitted_attributes(@user))
        # if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    authorize @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :fore_name, :last_name, :access_revoked, role_ids: [])
  end

end
