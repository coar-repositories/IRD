# frozen_string_literal: true

module MachineReadability
  extend ActiveSupport::Concern
  require 'csv'

  class MachineReadableAttribute
    attr_reader :label, :method, :include_for_ingest

    def initialize(label, method, include_for_ingest = false)
      @label = label
      @method = method
      @include_for_ingest = include_for_ingest
    end
  end

  class MachineReadableAttributeSet
    # attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def attributes(for_ingest = false)
      if for_ingest
        @attributes.select { |attribute| attribute.include_for_ingest == true }
      else
        @attributes
      end
    end

    def labels(for_ingest = false)
      attributes(for_ingest).map(&:label)
    end
  end

  Default_machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                          MachineReadableAttribute.new(:id, "entity.id"),
                                                                          MachineReadableAttribute.new(:name, "entity.name"),
                                                                          MachineReadableAttribute.new(:created_at, "entity.created_at"),
                                                                          MachineReadableAttribute.new(:updated_at, "entity.updated_at")
                                                                        ])

  class_methods do
    def to_csv(collection, for_ingest = false)
      CSV.generate(col_sep: ',') do |csv|
        csv << machine_readable_attributes.labels(for_ingest)
        collection.each do |entity|
          row = []
          machine_readable_attributes.attributes(for_ingest).each do |attribute|
            attribute = eval(attribute.method)
            if attribute.is_a?(Array)
              row << attribute.join("|")
            else
              row << attribute
            end
          end
          csv << row
        end
      end
    end
  end

end
