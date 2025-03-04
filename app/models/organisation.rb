class Organisation < ApplicationRecord
  include Curation
  include MachineReadability

  searchkick max_result_window: 200000

  def search_data
    {
      name: name,
      short_name: short_name,
      aliases: aliases
    }
  end

  belongs_to :country
  has_many :ownerships, class_name: 'System', foreign_key: 'owner_id'
  has_many :responsibilities, class_name: 'System', foreign_key: 'rp_id'
  has_and_belongs_to_many :users, :join_table => 'organisations_users'

  scope :rps, -> { where(rp: true) }
  scope :in_country, ->(country_id) { where(country_id: country_id) }

  validates :ror, uniqueness: { allow_nil: true, allow_blank: true }

  before_create :set_id
  before_save :initialise_for_saving
  before_save :update_domain
  before_save :extract_short_name_from_aliases

  Machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, :string, "entity.id"),
                                                                  MachineReadableAttribute.new(:name, :string, "entity.name"),
                                                                  MachineReadableAttribute.new(:ror, :string, "entity.ror"),
                                                                  MachineReadableAttribute.new(:website, :string, "entity.website"),
                                                                  MachineReadableAttribute.new(:country_id, :string, "entity.country_id"),
                                                                  MachineReadableAttribute.new(:repositories_owned, :integer, "entity.ownerships.count"),
                                                                  MachineReadableAttribute.new(:responsibilities, :integer, "entity.responsibilities.count")
                                                                ])

  def self.default_rp_for_archived_records_id
    Rails.application.config.ird[:default_models][:rp_for_archived_records]
  end

  def self.default_rp_for_archived_records
    Organisation.find(self.default_rp_for_archived_records_id)
  end

  def self.default_rp_for_published_records_id
    Rails.application.config.ird[:default_models][:rp_for_published_records]
  end

  def self.default_rp_for_published_records
    Organisation.find(self.default_rp_for_published_records_id)
  end

  def self.machine_readable_attributes
    Machine_readable_attributes
  end

  def display_name
    if self.short_name.blank?
      self.name
    else
      self.short_name
    end
  end

  def add_alias(new_name)
    unless self.aliases
      self.aliases = []
    end
    self.aliases << new_name
    self.aliases.uniq!
  end

  def self.rp_for_country(country_id)
    rp = nil
    rps = self.where(rp: true, country_id: country_id)
    if rps.count == 1
      rp = rps.first
    end
    rp
  end

  def make_rp!
    self.rp = true
    self.save!
  end

  def is_rp?
    self.rp
  end

  def responsibilities_active
    responsibilities.system_status_online
  end

  private

  def set_id
    if self.id == nil
      self.id = SecureRandom.uuid
    end
  end

  def initialise_for_saving
    self.aliases ||= []
    self.aliases.compact_blank!
  end

  def update_domain
    self.domain = Utilities::UrlUtility.get_domain_from_url(self.website)
  end

  def extract_short_name_from_aliases
    if self.short_name.blank?
      self.aliases.each do |a|
        if a.size < 20 || !a.include?(' ')
          self.short_name = a
        end
      end
    end
  end
end
