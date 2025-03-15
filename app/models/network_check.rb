class NetworkCheck < ApplicationRecord
  include TranslateEnum

  enum :network_check_type, { homepage_url: 0, oai_pmh_identify: 1 }, prefix: true, default: :homepage_url
  translate_enum :network_check_type

  belongs_to :system

  before_create :set_id
  before_save :update_error_status

  def self.error_count_threshold
    Rails.application.config.ird[:network_check_failure][:error_count_threshold].to_i
  end

  scope :url_checks, -> { where network_check_type: :homepage_url }
  scope :oai_checks, -> { where network_check_type: :oai_pmh_identify }
  scope :failures, -> { where passed: false }
  scope :homepage_url_failed, -> { where network_check_type: :homepage_url, passed: false}
  scope :oai_pmh_identify_failed, -> { where network_check_type: :oai_pmh_identify, passed: false}
  scope :failures_no_network_connection, -> { where http_code: 0 }

  def errors_past_threshold?
    self.failures >= Rails.application.config.ird[:network_check_failure][:error_count_threshold] && self.error_duration >= Rails.application.config.ird[:network_check_failure][:error_duration_threshold]
  end

  def error_duration
    if self.error_at.nil?
      return 0
    end
    ((self.updated_at - self.error_at) / 1.day).floor
  end

  private
  def set_id
    if self.id == nil
      self.id = SecureRandom.uuid
    end
  end

  def update_error_status
    if self.passed
      self.failures = 0
      self.error_at = nil
    else
      self.error_at = Time.now if self.error_at.nil?
      self.failures += 1
    end
  end
end
