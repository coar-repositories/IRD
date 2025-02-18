module SystemsHelper

  def full_identifier(scheme, id)
    scheme = scheme.to_sym
    if Rails.application.config.ird.repo_id_schemes[scheme]
      prefix = Rails.application.config.ird.repo_id_schemes[scheme][:prefix]
      if prefix
        prefix + id
      else
        id
      end
    else
      id
    end
  end

  def resolvable_identifier(scheme, id)
    scheme = scheme.to_sym
    if Rails.application.config.ird.repo_id_schemes[scheme]
      if Rails.application.config.ird.repo_id_schemes[scheme][:url]
        prefix = Rails.application.config.ird.repo_id_schemes[scheme][:url][:prefix]
        suffix = Rails.application.config.ird.repo_id_schemes[scheme][:url][:suffix]
        id_to_display = full_identifier(scheme, id)
        if scheme == :IRD
          "<a href=\"#{prefix}#{id}#{suffix}\">#{id_to_display}</a>".html_safe
        else
          "<a href=\"#{prefix}#{id}#{suffix}\">#{id_to_display}</a>".html_safe
        end
      else
        id
      end
    else
      id
    end
  end

  def annotation_flags(annotation)
    "<span class='badge rounded-pill text-bg-light'>#{annotation.name}</span>".html_safe
  end

  def tag_flags(tag)
    "<span class='badge rounded-pill text-bg-light'>#{tag}</span>".html_safe
  end

  def system_status_flags(status)
    status_sym = status.to_sym
    case status_sym
    when :unknown
      badge_class = 'text-bg-secondary'
    when :online
      badge_class = 'text-bg-success'
    when :offline
      badge_class = 'text-bg-warning'
    when :missing
      badge_class = 'text-bg-danger'
    else
      badge_class = 'text-bg-secondary'
    end
    # i18n-tasks-use t("activerecord.attributes.system.system_status_list.#{status}") # this lets i18n-tasks know the key is used
    "<span class='badge rounded-pill #{badge_class}'>#{System.translated_system_status status_sym}</span>".html_safe
  end

  def oai_status_flags(status)
    status_sym = status.to_sym
    case status_sym
    when :unknown
      badge_class = 'text-bg-secondary'
    when :online
      badge_class = 'text-bg-success'
    when :not_enabled
      badge_class = 'text-bg-warning'
    when :offline
      badge_class = 'text-bg-warning'
    when :unsupported
      badge_class = 'text-bg-danger'
    else
      badge_class = 'text-bg-secondary'
    end
    # i18n-tasks-use t("activerecord.attributes.system.oai_status_list.#{status}") # this lets i18n-tasks know the key is used
    "<span class='badge rounded-pill #{badge_class}'>#{System.translated_oai_status status_sym}</span>".html_safe
  end

  # def record_status_flags(status, show_drafts = true)
  #   status_sym = status.to_sym
  #   case status_sym
  #   when :draft
  #     badge_class = 'text-bg-secondary'
  #   when :published
  #     badge_class = 'text-bg-success'
  #   when :archived
  #     badge_class = 'text-bg-danger'
  #   else
  #     badge_class = 'text-bg-secondary'
  #   end
  #   unless !show_drafts && status_sym == :draft
  #     # i18n-tasks-use t("activerecord.attributes.system.record_status_list.#{status}") # this lets i18n-tasks know the key is used
  #     "<span class='badge rounded-pill #{badge_class}'>#{System.translated_record_status status_sym}</span>".html_safe
  #   end
  # end

  def record_status_flags(status)
    status_sym = status.to_sym
    case status_sym
    when :draft
      badge_class = 'text-bg-secondary'
    when :published
      badge_class = 'text-bg-success'
    when :archived
      badge_class = 'text-bg-danger'
    when :under_review
      badge_class = 'text-bg-warning'
    else
      badge_class = 'text-bg-secondary'
    end
    # badge_class = 'text-bg-secondary'
    "<span class='badge rounded-pill #{badge_class}'>#{System.translated_record_status status_sym}</span>".html_safe
  end

  def network_check_result_flags(network_check)
    if !network_check
      "<span class='bi-question-square-fill' title= 'Unknown' data-toggle='tooltip'></span><span class='sortable-hidden'>1</span>".html_safe
    else
      case network_check.passed
      when true
        "<span class='bi-check-square-fill green-icon' title= 'Success' data-toggle='tooltip'></span><span class='sortable-hidden'>0</span>".html_safe
      else
        "<span class='bi-x-square-fill red-icon' title= 'Failure' data-toggle='tooltip'></span><span class='sortable-hidden'>2</span>".html_safe
      end
    end
  end

  def issue_priority_flags(issue)
    priority_sym = issue['priority'].to_sym
    case priority_sym
    when :high
      badge_class = 'bi-exclamation-triangle-fill red-icon'
    when :medium
      badge_class = 'bi-exclamation-triangle-fill orange-icon'
    when :low
      badge_class = 'bi-exclamation-triangle-fill yellow-icon'
    else
      badge_class = 'bi-exclamation-triangle-fill'
    end
    "<span class='#{badge_class}'></span> #{issue['description']}".html_safe
  end

end
