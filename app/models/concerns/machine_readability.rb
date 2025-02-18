# frozen_string_literal: true

module MachineReadability
  extend ActiveSupport::Concern
  require 'csv'
  MachineReadableAttribute = Struct.new(:label, :method)

  class MachineReadableAttributeSet
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def labels
      @attributes.map(&:label)
    end
  end

  Default_machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, "entity.id"),
                                                                  MachineReadableAttribute.new(:name, "entity.name"),
                                                                  MachineReadableAttribute.new(:created_at, "entity.created_at"),
                                                                  MachineReadableAttribute.new(:updated_at, "entity.updated_at")
                                                                ])

  class_methods do
    def to_csv(collection)
      CSV.generate(col_sep: ',') do |csv|
        csv << machine_readable_attributes.labels
        collection.each do |entity|
          row = []
          machine_readable_attributes.attributes.each do |attribute|
            row << eval(attribute[:method])
          end
          csv << row
        end
      end
    end
  end

end
