class AdminController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :admin
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
    conditions[:annotations] = params[:annotations] if params[:annotations].present?
    conditions[:tags] = params[:tags] if params[:tags].present?
    conditions[:subcategory] = params[:subcategory] if params[:subcategory].present?
    conditions[:media] = params[:media] if params[:media].present?
    conditions[:primary_subject] = params[:primary_subject] if params[:primary_subject].present?
    conditions[:has_thumbnail] = params[:has_thumbnail] if params[:has_thumbnail].present?
    conditions[:has_owner] = params[:has_owner] if params[:has_owner].present?
    conditions[:rp] = params[:rp] if params[:rp].present?
    conditions[:http_code] = params[:http_code] if params[:http_code].present?
    conditions[:metadata_formats] = params[:metadata_formats] if params[:metadata_formats].present?
    conditions[:identifier_schemes] = params[:identifier_schemes] if params[:identifier_schemes].present?
    unless params[:show_archived_records] == 'true'
      conditions[:_not] = { record_status: 'archived' }
    end

    page = params[:page] || 1
    per_page = params[:items] || Rails.application.config.ird[:catalogue_default_page_size].to_i

    facets = [:country, :continent, :platform, :system_status, :oai_status, :record_status, :record_source, :subcategory, :media, :primary_subject, :annotations, :tags, :rp, :http_code, :has_thumbnail, :has_owner, :metadata_formats, :identifier_schemes]

    @unpaginated_systems = System.search(
      search_terms,
      where: conditions,
      aggs: facets,
      body_options: {
        track_total_hits: true
      },
      includes: [:network_checks,:repoids,:media,:annotations,:users, :metadata_formats]
    )

    @systems = System.search(
      search_terms,
      where: conditions,
      order: { name: :asc },
      aggs: facets,
      page: page,
      per_page: per_page,
      includes: [:network_checks,:repoids,:media,:annotations,:users, :metadata_formats]
    )

    @facets = @systems.aggs
    # @stats = get_stats(System.all)
    # @filtered_stats = get_stats(@systems)
    if params[:operation].present? && policy(:admin).perform_batch_operations?
      case params[:operation].to_sym
      when :annotate
        annotation = Annotation.find(params[:annotation_to_process])
        ActiveJob.perform_all_later(@unpaginated_systems.map { |system| AnnotateJob.new(system.id, annotation, params[:add_or_remove].to_sym) })
        redirect_back fallback_location: root_path, notice: "Started annotation job for #{@unpaginated_systems.count} systems with (#{params[:add_or_remove]}) annotation '#{annotation.name}'"
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
        Annotation.find('duplicate').systems.each do |system|
          system.destroy!
          count += 1
        end
        # redirect_to admin_url(request.query_parameters.except(:operation, :lang)), notice: "Started auto-curating #{@unpaginated_systems.count} systems..."
        redirect_back fallback_location: root_path, notice: "Purged #{count} duplicates."
      when :purge_thumbnails
        count = 0
        @unpaginated_systems.each do |system|
          if system.thumbnail.attached?
            system.thumbnail.purge
            count += 1
          end
        end
        # redirect_to admin_url(request.query_parameters.except(:operation, :lang)), notice: "Started purging thumbnails from #{count} systems..."
        redirect_back fallback_location: root_path, notice: "Started purging thumbnails from #{count} systems..."
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
        @pagy = Pagy.new_from_searchkick(@systems)
      end
      format.csv do
        send_data System.to_csv(@unpaginated_systems), filename: ActiveStorage::Filename.new(@page_title).sanitized, content_type: 'text/csv'
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
