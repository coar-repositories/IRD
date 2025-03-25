module ApplicationHelper
  include Pagy::Frontend

  def stats_for_system_set(systems)
    Stats::SystemSetStatsService.call(systems)
  end

  def boolean_facet_value_from_integer(value)
    value == 1
  end

  def display_boolean_facet_value(value)
    if value == 1
      'True'
    else
      'False'
    end
  end

  def calculate_facet_rows_breakpoint(total, desired_columns)
    (total / desired_columns.to_f).ceil
  end

  # def display_search_terms_from_params(params)
  #   params.except!(:lang)
  #   if params.empty?
  #     return nil
  #   end
  #   output = 'You searched for:'
  #   output += '<ul>'
  #   params.each do |param|
  #     if param[1].nil? || param[1].blank?
  #       next
  #     else
  #       output += "<li>#{param[0]}: #{param[1]}</li>"
  #     end
  #     # output += "<li>#{param[0]}: #{param[1]}</li>" unless param[1].blank?
  #   end
  #   output += '</ul>'
  #   output.html_safe
  # end



  def oai_pmh_facet_label(entity)
    if entity
      'Supported'
    else
      'Not supported'
    end
  end

  def print_field_name_and_value(name, value,include_fields_with_empty_values = true)
    content = ''
    unless value.blank? && !include_fields_with_empty_values
      value = 'None' if value.nil?
      content = "<div class=\"property\">"
      content += "<h5 class=\"property-name\">#{name}</h5>"
      content += "<div class=\"property-value\">#{value}</div>"
      content += "</div>"
    end
    content.html_safe
  end

  def percentage(n, total)
    Utilities::NumberUtility.get_percentage(n, total)
  end

  def green_tick_or_red_cross(boolean_value)
    if boolean_value
      '✅'
    else
      '❌'
    end
  end

  def stuff_protocol_into_url(url, format)
    end_of_path_index = url.index('?')
    if end_of_path_index
      url[..(end_of_path_index - 1)] + '.' + format + url[end_of_path_index..]
    else
      url + '.' + format
    end
  end

  def test_user_account_email_addresses
    email_addresses = []
    email_addresses = ENV['TEST_USER_ACCOUNTS'].split(',') if ENV['TEST_USER_ACCOUNTS']
    email_addresses
  end

end
