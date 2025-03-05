json.id entity.id
json.type entity.class.name.pluralize.downcase
json.attributes do
  model_attributes.attributes.each do |attribute|
    json.set!(attribute.label, eval(attribute.method))
  end
end
json.links do
  json.self polymorphic_url entity
end
