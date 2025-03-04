class Country < ApplicationRecord
  include TranslateEnum
  include MachineReadability

  enum :continent, { global: 0, africa: 1, antarctica: 2, asia: 3, central_america: 4, europe: 5, north_america: 6, oceania: 7, south_america: 8 }, prefix: true, default: :global
  translate_enum :continent

  has_many :organisations
  has_many :systems

  Machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, :string, "entity.id"),
                                                                  MachineReadableAttribute.new(:name, :string, "entity.name"),
                                                                  MachineReadableAttribute.new(:repositories, :integer, "entity.systems.count")
                                                                ])

  def self.machine_readable_attributes
    Machine_readable_attributes
  end

  def self.default_id
    '--'
  end
  def self.default
    self.find(self.default_id)
  end

  def responsible_parties
    self.organisations.where(rp: true)
  end

  def system_count
    self.systems.count
  end

end
