json.partial! '_shared/json_common'

json.links do
  json.self self_url
end

json.data do
  json.partial! '_shared/json_entity', entity: entity, model_attributes: model_attributes
end