require 'addressable/uri'

def build_paginated_url(addressable_url, page)
  if page && page > 0
    params = addressable_url.query_values || {}
    params['page'] = page
    addressable_url.query_values = params
    addressable_url.to_s
  else
    nil
  end
end

if @pagy
  addressable_url = Addressable::URI.parse(self_url)
  first_page_url = build_paginated_url(addressable_url, 1)
  prev_page_url = build_paginated_url(addressable_url, @pagy.prev)
  next_page_url = build_paginated_url(addressable_url, @pagy.next)
  last_page_url = build_paginated_url(addressable_url, @pagy.last)
else
  last_page_url = nil
end

json.partial! '_shared/json_common'

json.links do
  json.self self_url
  json.first first_page_url
  json.prev prev_page_url #unless prev_page_url.nil?
  json.next next_page_url #unless next_page_url.nil?
  json.last last_page_url
end

json.data do
  json.array! entities do |entity|
    json.partial! '_shared/json_entity', entity: entity, model_attributes: model_attributes
  end
end