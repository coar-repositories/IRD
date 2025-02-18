# json.partial! '_shared/json_list', self_url: request.original_url, entities: @systems, model_attributes: [:name]
json.partial! '_shared/json_list', self_url: request.original_url, entities: @systems, model_attributes: System.machine_readable_attributes
