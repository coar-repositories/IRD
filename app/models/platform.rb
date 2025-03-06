class Platform < ApplicationRecord
  include MachineReadability
  has_many :systems
  has_many :generators, dependent: :delete_all

  before_create :set_id
  before_save :initialise_for_saving

  validate :matchers_must_be_regex,:generator_patterns_must_be_regex

  Machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, :string, "entity.id"),
                                                                  MachineReadableAttribute.new(:name, :string, "entity.name"),
                                                                  MachineReadableAttribute.new(:repositories, :integer, "entity.systems.count")
                                                                ])

  def self.machine_readable_attributes
    Machine_readable_attributes
  end

  def self.default_platform_id
    Rails.application.config.ird[:default_models][:platform]
  end

  def self.default_platform
    Platform.find(Platform.default_platform_id)
  end

  def trusted?
    self.trusted == true
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
    self.generator_patterns ||= []
    self.generator_patterns.uniq!
    self.generator_patterns.compact_blank!
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

  def generator_patterns_must_be_regex
    if self.generator_patterns.present?
      self.generator_patterns.uniq!
      self.generator_patterns.compact_blank!
      self.generator_patterns.each do |pattern|
        begin
          reg = eval pattern
          unless reg.is_a? Regexp
            errors.add(:generator_patterns, "Invalid matcher regex: '#{pattern}'")
          end
        rescue
          errors.add(:generator_patterns, "Invalid matcher regex: '#{pattern}'")
        end
      end
    end
  end
end
