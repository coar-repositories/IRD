class MetadataFormat < ApplicationRecord
  include MachineReadability

  has_and_belongs_to_many :systems, :join_table => 'metadata_formats_systems', strict_loading: false


  before_create :set_id
  before_save :initialise_for_saving
  validate :matchers_must_be_regex

  Machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, :string, "entity.id"),
                                                                  MachineReadableAttribute.new(:name, :string, "entity.name")
                                                                ])

  def self.machine_readable_attributes
    Machine_readable_attributes
  end


  private

  def set_id
    if self.id == nil
      self.id = ActiveSupport::Inflector.parameterize(self.name)
    end
  end

  def initialise_for_saving
    self.matchers ||= []
    self.matchers.uniq!
    self.matchers.compact_blank!
    self.match_order ||= 100.0
  end

  def matchers_must_be_regex
    if self.matchers.present?
      self.matchers.uniq!
      self.matchers.compact_blank!
      self.matchers.each do |matcher|
        begin
          reg = eval matcher
          unless reg.is_a? Regexp
            errors.add(:matchers, "Invalid matcher regex: '#{matcher}'")
          end
        rescue
          errors.add(:matchers, "Invalid matcher regex: '#{matcher}'")
        end
      end
    end
  end
end
