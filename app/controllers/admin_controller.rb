class AdminController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :admin
    @csv_is_for_ingest = false
    @page_title = t('page_titles.admin')
    search_terms = params[:search].presence || "*"
    conditions = {}
    conditions[:country] = params[:country] if params[:country].present?
    conditions[:continent] = params[:continent] if params[:continent].present?
    conditions[:platform] = params[:platform] if params[:platform].present?
    conditions[:system_status] = params[:system_status] if params[:system_status].present?
    conditions[:oai_status] = params[:oai_status] if params[:oai_status].present?
    conditions[:record_status] = params[:record_status] if params[:record_status].present?
    conditions[:record_source] = params[:record_source] if params[:record_source].present?
    conditions[:media_types] = params[:media_types] if params[:media_types].present?
    conditions[:labels] = params[:labels] if params[:labels].present?
    conditions[:tags] = params[:tags] if params[:tags].present?
    conditions[:subcategory] = params[:subcategory] if params[:subcategory].present?
    conditions[:primary_subject] = params[:primary_subject] if params[:primary_subject].present?
    conditions[:rp] = params[:rp] if params[:rp].present?
    conditions[:http_code] = params[:http_code] if params[:http_code].present?
    conditions[:http_code_oai] = params[:http_code_oai] if params[:http_code_oai].present?
    conditions[:metadata_formats] = params[:metadata_formats] if params[:metadata_formats].present?
    conditions[:identifier_schemes] = params[:identifier_schemes] if params[:identifier_schemes].present?
    conditions[:curation_issues] = params[:curation_issues] if params[:curation_issues].present?
    unless params[:show_archived_records] == 'true'
      conditions[:_not] = { record_status: 'archived' }
    end

    page = params[:page] || 1
    per_page = params[:items] || Rails.application.config.ird[:catalogue_default_page_size].to_i

    facets = [:country, :continent, :platform, :system_status, :oai_status, :record_status, :record_source, :subcategory, :primary_subject, :media_types, :labels, :tags, :rp, :http_code, :http_code_oai, :metadata_formats, :identifier_schemes, :curation_issues]

    @unpaginated_systems = System.search(
      search_terms,
      where: conditions,
      aggs: facets,
      body_options: {
        track_total_hits: true
      },
      includes: [:network_checks, :repoids, :users, :metadata_formats]
    )

    @systems = System.search(
      search_terms,
      where: conditions,
      order: { name: :asc },
      aggs: facets,
      page: page,
      per_page: per_page,
      includes: [:network_checks, :repoids, :users, :metadata_formats]
    )

    @facets = @systems.aggs
    # @stats = get_stats(System.all)
    # @filtered_stats = get_stats(@systems)
    if params[:operation].present? && policy(:admin).perform_batch_operations?
      case params[:operation].to_sym
      when :label
        label_to_process = params[:label_to_process]
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| LabelJob.new(system.id, label_to_process, params[:add_or_remove].to_sym) })
        redirect_back fallback_location: root_path, notice: "Started label job for #{@unpaginated_systems.count} systems with (#{params[:add_or_remove]}) label " + t("labels.#{label_to_process}")
      when :check_urls
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| CheckUrlJob.new(system.id, true) })
        redirect_back fallback_location: root_path, notice: "Started URL checking job for #{@unpaginated_systems.count} systems..."
      when :check_oai_identify
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| CheckOaiPmhIdentifyJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started OAI-PMH identify job for #{@unpaginated_systems.count} systems..."
      when :check_oai_formats
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| CheckOaiPmhFormatsJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started OAI-PMH format checking job for #{@unpaginated_systems.count} systems..."
      when :scrape_websites
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| CreateWebsiteThumbnailJob.new(system.id, true) })
        redirect_back fallback_location: root_path, notice: "Started website scraping job for #{@unpaginated_systems.count} systems..."
      when :publish
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| RecordPublishJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started publishing record for #{@unpaginated_systems.count} systems..."
      when :archive
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| RecordArchiveJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started archiving record for #{@unpaginated_systems.count} systems..."
      when :make_draft
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| RecordMakeDraftJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started making record draft for #{@unpaginated_systems.count} systems..."
      when :make_record_under_review
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| RecordMakeUnderReviewJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started making record under review for #{@unpaginated_systems.count} systems..."
      when :set_record_reviewed
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| SetRecordReviewedJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started setting record reviewed for #{@unpaginated_systems.count} systems..."
      when :auto_curate
        # @unpaginated_systems.each { |system| AutoCurateJob.perform_later(system.id) }
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| AutoCurateJob.new(system.id) })
        # redirect_to admin_url(request.query_parameters.except(:operation, :lang)), notice: "Started auto-curating #{@unpaginated_systems.count} systems..."
        redirect_back fallback_location: root_path, notice: "Started auto-curating #{@unpaginated_systems.count} systems..."
      when :purge_duplicates
        count = 0
        System.tagged_with("duplicate", on: :labels).each do |system|
          system.destroy!
          count += 1
        end
        # redirect_to admin_url(request.query_parameters.except(:operation, :lang)), notice: "Started auto-curating #{@unpaginated_systems.count} systems..."
        redirect_back fallback_location: root_path, notice: "Purged #{count} duplicates."
      when :purge_thumbnails
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| PurgeThumbnailJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started purging thumbnails from #{@unpaginated_systems.count} systems..."
      when :allocate_rp
        rp = Organisation.find_by_id(params[:rp_id])
        if rp
          ActiveJob.perform_all_later(@unpaginated_systems.map { |system| AllocateRpJob.new(system.id, rp.id) })
          redirect_back fallback_location: root_path, notice: "Started allocating RP #{rp.display_name} for #{@unpaginated_systems.count} systems..."
        else
          redirect_back fallback_location: root_path, alert: "Unable to allocate RP with ID = #{params[:rp_id]}"
        end
      when :allocate_rps_by_country
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| AllocateRpByCountryJob.new(system.id) })
        redirect_back fallback_location: root_path, notice: "Started allocating RPs by country for #{@unpaginated_systems.count} systems..."
      when :purge_unused_generators
        count = 0
        Generator.all.each do |g|
          if g.systems.count == 0
            g.destroy!
            count += 1
          end
        end
        redirect_back fallback_location: root_path, notice: "Purged #{count} unused generators"
      when :reindex_systems
        ReindexSystemsJob.perform_later
        redirect_back fallback_location: root_path, notice: "Started reindexing systems."
      when :generate_csv_for_batch_ingest
        @csv_is_for_ingest = true
      else
        redirect_back fallback_location: root_path, alert: "Operation #{params[:operation]} is unknown"
      end
    end
    respond_to do |format|
      format.html do
        @pagy = Pagy.new_from_searchkick(@systems)
        @record_count = @pagy.count
      end
      format.json do
        authorize :admin, :download_json?
        @pagy = Pagy.new_from_searchkick(@systems)
      end
      format.csv do
        authorize :admin, :download_csv?
        send_data System.to_csv(@unpaginated_systems, @csv_is_for_ingest), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
      end
    end
  end

  def authenticate_as
    authorize :admin
    user = User.find_by_email(params[:email])
    if user
      session = Passwordless::Session.create!(authenticatable: user)
      request.session[session_key(user.class)] = session.id
      redirect_to user_root_path, notice: "Signed in as #{user.email}"
    else
      redirect_to root_url, notice: "No user with email #{params[:email]}"
    end
  end

end
