json.partial! '_shared/json_list', self_url: request.original_url, entities: @users, model_attributes: User.machine_readable_attributes

