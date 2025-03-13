class PublishedSystemValidator < ActiveModel::Validator
  def validate(record)
    if record.record_status == "published"
      # i18n-tasks-use t('activerecord.errors.models.system.attributes.system_status.not_online') # this lets i18n-tasks know the key is used
      record.errors.add(:system_status, :not_online) unless record.system_status_online?
      # i18n-tasks-use t('activerecord.errors.models.system.attributes.oai_status.not_supported') # this lets i18n-tasks know the key is used
      record.errors.add(:oai_status, :not_supported) if record.oai_status_unsupported? || record.oai_status_unknown?
      if record.subcategory == "unknown"
        record.errors.add :subcategory, :missing
      end
      if record.primary_subject == "unknown"
        record.errors.add :primary_subject, :missing
      end
      if record.media_types.count == 0
        record.errors.add :media_types, :missing
      end
    end
  end
end

class UrlValidator < ActiveModel::Validator
  def validate(record)
    # i18n-tasks-use t('activerecord.errors.models.system.attributes.url.invalid') # this lets i18n-tasks know the key is used
    unless Utilities::UrlUtility.validate_url(record.url)
      record.errors.add :url, :invalid
    end
  end
end

class System < ApplicationRecord
  Issue = Struct.new(:priority, :description)
  include TranslateEnum
  include MachineReadability
  include ActiveSnapshot

  has_snapshot_children do
    instance = self.class.includes(:taggings, :repoids, :normalids).find(id)
    {
      taggings: instance.taggings,
      repoids: instance.repoids,
      normalids: instance.normalids
    }
  end

  searchkick max_result_window: 20000, deep_paging: true
  acts_as_taggable_on :tags, :labels # labels are from a *controlled* vocab, used for operations

  def search_data
    {
      name: name,
      short_name: short_name,
      aliases: aliases,
      country: country.name,
      continent: country.continent,
      platform: platform.name,
      record_status: record_status,
      system_status: system_status,
      oai_status: oai_status,
      record_source: record_source,
      subcategory: subcategory,
      media_types: media_types,
      primary_subject: primary_subject,
      tags: tags.map(&:name),
      labels: labels.map(&:name),
      rp: rp.display_name,
      http_code: network_checks.url_checks.first&.http_code,
      metadata_formats: metadata_formats.map(&:name),
      identifier_schemes: repoids.map(&:identifier_scheme).excluding("ird").uniq,
      curation_issues: issues.map { |issue| issue["description"] }
    }
  end

  scope :search_import, -> { includes(:country, :platform, :tags, :rp, :owner, :network_checks) } # avoids n+1 queries

  enum :system_category, { unknown: 0, repository: 1, service: 2 }, prefix: true, default: :unknown, scopes: true
  translate_enum :system_category

  enum :subcategory, { unknown: 0, institutional_repository: 1, disciplinary_repository: 2, generalist_repository: 3, governmental_repository: 4 }, prefix: true, default: :unknown, scopes: true
  translate_enum :subcategory

  enum :system_status, { unknown: 0, offline: 1, online: 2, missing: 3 }, prefix: true, default: :unknown, scopes: true
  translate_enum :system_status

  enum :oai_status, { unknown: 0, unsupported: 1, offline: 2, online: 3, not_enabled: 4 }, prefix: true, default: :unknown, scopes: true
  translate_enum :oai_status

  enum :record_status, { draft: 0, published: 1, archived: 2, under_review: 3 }, prefix: true, default: :draft, scopes: true
  translate_enum :record_status

  enum :primary_subject, { unknown: 0, multidisciplinary: 1, arts: 2, engineering: 3, health_and_medicine: 4, humanities: 5, law: 6, mathematics: 7, science: 8, social_sciences: 9, technology: 10 }, prefix: true, default: :unknown, scopes: true
  translate_enum :primary_subject

  belongs_to :platform
  belongs_to :owner, class_name: "Organisation", optional: true
  belongs_to :rp, class_name: "Organisation", optional: true
  belongs_to :country, optional: true
  belongs_to :generator, optional: true
  has_many :network_checks, dependent: :delete_all, strict_loading: false
  has_many :normalids, dependent: :delete_all, strict_loading: false
  has_many :repoids, dependent: :delete_all, strict_loading: false # strict_loading: false because of the de-duplication code
  accepts_nested_attributes_for :repoids, allow_destroy: true, reject_if: lambda { |attributes| attributes["identifier_value"].blank? }
  has_and_belongs_to_many :users, :join_table => "systems_users", strict_loading: false
  has_and_belongs_to_many :metadata_formats, :join_table => "metadata_formats_systems", strict_loading: false
  has_one_attached :thumbnail, service: :thumbnails

  scope :has_owner, -> { where.not(owner_id: nil) }
  scope :in_country, ->(country_id) { where(country_id: country_id) }
  scope :no_thumbnail, -> { where.missing(:thumbnail_attachment) }
  scope :publicly_viewable, -> { where.not(record_status: :unknown).where.not(record_status: :draft).where.not(record_status: :archived) }
  # scope :duplicates, -> { includes(:annotations).where(annotations: { id: "duplicate" }) }

  validates :name, :url, presence: true
  validates_with UrlValidator, on: :create
  validates_with PublishedSystemValidator

  before_validation :set_defaults
  before_save :initialise_for_saving
  before_save :update_country_before_save
  before_save :curation_check
  after_save :update_normalids_after_save
  after_create :add_id_to_repoids_after_create
  after_create :add_url_to_normalids_on_create

  Machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, :string, "entity.id", true),
                                                                  MachineReadableAttribute.new(:name, :string, "entity.name", true),
                                                                  MachineReadableAttribute.new(:system_category, :string, "entity.system_category", true),
                                                                  MachineReadableAttribute.new(:homepage, :string, "entity.url", true),
                                                                  MachineReadableAttribute.new(:owner_id, :string, "entity.owner.id if entity.owner", true),
                                                                  MachineReadableAttribute.new(:owner_homepage, :string, "entity.owner.website if entity.owner", true),
                                                                  MachineReadableAttribute.new(:contact, :string, "entity.contact", true),
                                                                  MachineReadableAttribute.new(:owner_ror, :string, "entity.owner.ror if entity.owner", true),
                                                                  MachineReadableAttribute.new(:owner_name, :string, "entity.owner.name if entity.owner", true),
                                                                  MachineReadableAttribute.new(:repository_type, :string, "entity.subcategory", true),
                                                                  MachineReadableAttribute.new(:system_status, :string, "entity.system_status", false),
                                                                  MachineReadableAttribute.new(:software, :string, "entity.platform_id", true),
                                                                  MachineReadableAttribute.new(:software_version, :string, "entity.platform_version", true),
                                                                  MachineReadableAttribute.new(:country, :string, "entity.country_id", false),
                                                                  MachineReadableAttribute.new(:responsible_organisation, :string, "entity.rp.name if entity.rp", false),
                                                                  MachineReadableAttribute.new(:other_registry_identifiers, :array, "entity.repoids.third_party.collect(&:to_s)", true),
                                                                  MachineReadableAttribute.new(:oai_base_url, :string, "entity.oai_base_url", true),
                                                                  MachineReadableAttribute.new(:oai_status, :string, "entity.oai_status", false),
                                                                  MachineReadableAttribute.new(:media_types, :array, "entity.media_types", true),
                                                                  MachineReadableAttribute.new(:primary_subject, :string, "entity.primary_subject", true),
                                                                  MachineReadableAttribute.new(:reviewed, :timestamp, "entity.reviewed", false),
                                                                  MachineReadableAttribute.new(:metadata_formats, :array, "entity.metadata_formats.collect(&:name)", false),
                                                                  MachineReadableAttribute.new(:record_status, :string, "entity.record_status", true)
                                                                ])

  def self.machine_readable_attributes
    Machine_readable_attributes
  end

  def self.unrestricted_labels
    Rails.configuration.ird[:labels].select { |_, v| v[:restricted] == false }.keys
  end

  def most_recent_snapshot(user = nil)
    if user
      snapshots.where(user_id: user.id).order(created_at: :desc).first
    else
      snapshots.order(created_at: :desc).first
    end
  end

  def display_name
    if !self.short_name.blank?
      self.short_name
    else
      self.name
    end
  end

  def mark_reviewed!
    self.reviewed = Time.zone.now
  end

  def review_due?
    self.reviewed.nil? || self.reviewed < Rails.configuration.ird[:system_review_period].days.ago
  end

  def published?
    self.record_status == "published"
  end

  def publish!
    self.record_status = :published
    self.mark_reviewed!
  end

  def archive!
    self.record_status = :archived
    self.rp_id = Organisation.default_rp_for_archived_records_id
    self.users.clear
    self.mark_reviewed!
  end

  def review!
    self.record_status = :under_review
  end

  def draft!
    self.record_status = :draft
    self.rp_id = Organisation.default_rp_for_archived_records_id
  end

  def add_repo_id(repo_id_scheme, repo_id_value)
    begin
      Repoid.create!({ identifier_scheme: Repoid.identifier_schemes[repo_id_scheme.downcase.to_sym], identifier_value: repo_id_value, system_id: self.id })
    rescue Exception => e
      Rails.logger.warn "unable to add repo id (#{repo_id_scheme}, #{repo_id_value}) for system #{self.id}: #{e.message}"
    end
  end

  def network_check(network_check_type)
    self.network_checks.where(network_check_type: network_check_type).first
  end

  def write_network_check(network_check_type, passed, description, http_code)
    nc = NetworkCheck.find_or_create_by(system_id: self.id, network_check_type: network_check_type)
    nc.passed = passed
    nc.description = description
    nc.http_code = http_code
    nc.save!
  end

  def curation_check
    issue_array = []
    issue_array << Issue.new(:high, "name-missing") if self.name.blank?
    issue_array << Issue.new(:high, "homepage-url-missing") if self.url.blank?
    issue_array << Issue.new(:high, "oai-base-url-missing") if self.system_category == "repository" && self.oai_base_url.blank?
    issue_array << Issue.new(:medium, "owner-missing") unless self.owner
    self.network_checks.each do |nc|
      unless nc.passed
        case nc.network_check_type
        when "homepage_url"
          issue_array << Issue.new(:high, "automated-website-check-failed")
        when "oai_pmh_identify"
          issue_array << Issue.new(:high, "automated-oai-pmh-check-failed")
        end
      end
      # i18n-tasks-use t("activerecord.attributes.network_check.network_check_type_list.#{network_check_type}") # this lets i18n-tasks know the key is used
    end
    issue_array << Issue.new(:medium, "platform-missing") if self.platform_id == Platform.default_platform_id
    if self.generator
      issue_array << Issue.new(:medium, "platform-may-be-incorrect") if self.generator.platform&.trusted && (self.generator.platform_id != self.platform_id)
      issue_array << Issue.new(:medium, "platform-version-may-be-incorrect") if self.generator.platform == self.platform && self.generator.version != self.platform_version
    else
      # self.curation_alerts << Issue.new(:warning, 'Generator is unknown') # is this useful?
    end
    issue_array << Issue.new(:low, "description-missing") if self.description.blank?
    issue_array << Issue.new(:low, "contact-missing") if self.contact.blank?
    issue_array << Issue.new(:low, "thumbnail-missing") unless self.thumbnail.attached?
    self.issues = issue_array
  end

  def add_normalid_for_url(url)
    begin
      Normalid.create!({ url: Utilities::UrlUtility.get_normalised_url(url), system_id: self.id }) unless url.blank?
    rescue Exception => e
      Rails.logger.warn "unable to add normal id (#{url}) for system #{self.id}: #{e.message}"
    end
  end

  def unknown_platform?
    !self.platform || self.platform.id == Platform.default_platform_id
  end

  def has_oai_pmh_identify_failures_past_threshold?
    !self.network_checks.oai_pmh_identify_failed.failures_past_threshold.blank?
  end

  def update_from_duplicate_system(duplicate_system)
    Repoid.where(system_id: duplicate_system.id).each do |repoid|
      unless repoid.identifier_scheme == "ird"
        begin
          self.add_repo_id(repoid.identifier_scheme, repoid.identifier_value)
        rescue Exception => e
          Rails.logger.warn "unable to add repo id (#{repoid.identifier_scheme}, #{repoid.identifier_value}) for system #{self.id}: #{e.message}"
        end
      end
    end
    if (self.media_types.is_a? Array) && (self.media_types.empty?)
      duplicate_system.media_types.each do |media_type|
        self.media_types << media_type
      end
    end
    self.oai_base_url = duplicate_system.oai_base_url if self.oai_base_url.blank?
    if self.unknown_platform?
      self.platform = duplicate_system.platform
      self.platform_version = duplicate_system.platform_version
    end
    self.aliases << duplicate_system.name
    duplicate_system.aliases.each do |a|
      self.aliases << a
    end
    self.owner = duplicate_system.owner unless self.owner
    self.primary_subject = duplicate_system.primary_subject if self.primary_subject_unknown?
    self.name = duplicate_system.name if self.name.blank?
    self.description = duplicate_system.description if self.description.blank?
    self.country_id = duplicate_system.country_id if self.country_id.blank?
    self.subcategory = duplicate_system.subcategory if self.subcategory_unknown?
    self.url = duplicate_system.url if self.url.blank?
  end

  private

  def update_normalids_after_save
    if self.saved_change_to_url? && !self.url.blank?
      self.add_normalid_for_url(self.url)
    end
  end

  def update_country_before_save
    if will_save_change_to_attribute?(:owner_id) && self.owner
      self.country = self.owner.country
    end
  end

  def add_id_to_repoids_after_create
    Repoid.create!(system_id: self.id, identifier_scheme: :ird, identifier_value: self.id)
  end

  def add_url_to_normalids_on_create
    self.add_normalid_for_url(self.url)
  end

  def set_defaults
    begin
      if self.country_id.nil? || self.country_id.blank?
        if self.owner&.country_id
          self.country_id = self.owner.country_id
        end
        unless self.country_id && !self.country_id.blank?
          tld = Utilities::UrlUtility.get_tld_from_url(self.url)
          if tld
            country = Country.find_by_id(tld.upcase)
            self.country_id = country.id if country
          end
        end
        unless self.country_id && !self.country_id.blank?
          self.country_id = Country.default_id
        end
      end
      if self.platform_id.blank?
        self.platform_id = Platform.default_platform_id if self.platform_id.blank?
      end
      if self.rp_id.blank?
        self.rp = Organisation.default_rp_for_live_records
      end
      self.owner_id = nil if self.owner_id == ""
    rescue Exception => e
      Rails.logger.warn "unable to set defaults for system #{self.id}: #{e.message}"
    end

  end

  def initialise_for_saving
    if self.id == nil
      self.id = SecureRandom.uuid
    end
    # hashes
    self.metadata ||= {}
    self.formats ||= {}
    self.issues ||= {}
    # arrays
    self.aliases ||= []
    self.aliases.uniq!
    self.aliases.compact_blank!
    self.media_types ||= []
    self.media_types.uniq!
    self.media_types.compact_blank!
    if self.random_id.nil? || self.random_id == 0
      self.random_id = rand(1...1000000)
    end
    self.owner_id = nil if self.owner_id == ""
    # strip whitespace from beginning/end of strings caused by updates from spreadsheets or forms
    self.id.strip!
    self.name.strip! unless self.name.nil?
    self.short_name.strip! unless self.short_name.nil?
    self.url.strip! unless self.url.nil?
    self.oai_base_url.strip! unless self.oai_base_url.nil?
    self.description.strip! unless self.description.nil?
    self.contact.strip! unless self.contact.nil?
    self.platform_version.strip! unless self.platform_version.nil?
    self.aliases.each do |a|
      a.strip! unless self.name.nil?
    end
  end
end

