# frozen_string_literal: true

module MachineReadability
  extend ActiveSupport::Concern
  require 'csv'

  class MachineReadableAttribute
    attr_reader :label, :data_type, :method, :include_for_ingest

    def initialize(label, data_type, method, include_for_ingest = false)
      @label = label
      @method = method
      @data_type = data_type
      @include_for_ingest = include_for_ingest
    end
  end

  class MachineReadableAttributeSet

    def initialize(attributes)
      @attributes = attributes
    end

    def labels(for_ingest = false)
      attributes(for_ingest).map(&:label)
    end

    def attributes(for_ingest = false)
      if for_ingest
        @attributes.select { |attribute| attribute.include_for_ingest == true }
      else
        @attributes
      end
    end

    def to_hash(for_ingest = false)
      attributes_hash = {}
      attributes(for_ingest).each do |attribute|
        case attribute.data_type
        when :array
          attributes_hash[attribute.label.to_s] = []
        when :integer
          attributes_hash[attribute.label.to_s] = 0
        else
          attributes_hash[attribute.label.to_s] = nil
        end
      end
      attributes_hash
    end

  end

  Default_machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                          MachineReadableAttribute.new(:id, :string, "entity.id"),
                                                                          MachineReadableAttribute.new(:name, :string, "entity.name"),
                                                                          MachineReadableAttribute.new(:created_at, :timestamp, "entity.created_at"),
                                                                          MachineReadableAttribute.new(:updated_at, :timestamp, "entity.updated_at")
                                                                        ])

  class_methods do
    def to_csv(collection, for_ingest = false)
      CSV.generate(col_sep: ',') do |csv|
        csv << machine_readable_attributes.labels(for_ingest)
        collection.each do |entity|
          row = []
          machine_readable_attributes.attributes(for_ingest).each do |attribute|
            attribute_value = eval(attribute.method)
            case attribute.data_type
            when :array
              row << attribute_value.join("|")
            when :string
              row << attribute_value
            else
              row << attribute_value.to_s
            end
          end
          csv << row
        end
      end
    end
  end

end
