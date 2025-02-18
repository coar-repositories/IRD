class Generator < ApplicationRecord
  include MachineReadability
  belongs_to :platform
  has_many :systems

  before_create :set_id
  before_save :identify_platform
  before_validation :initialise_for_saving

  def unknown_platform?
    !self.platform || self.platform.id == '_unknown'
  end

  def self.machine_readable_attributes
    Default_machine_readable_attributes
  end

  def identify_platform
    if self.unknown_platform?
      Platform.all.order(:match_order).each do |platform|
        unless self.unknown_platform?
          break
        end
        if platform.generator_patterns.present?
          platform.generator_patterns.each do |pattern|
            begin
              reg = eval pattern
              matches = reg.match self.name
              if matches
                self.platform = platform
                if matches[2].present?
                  version = matches[2].strip
                  if version.size > 50
                    self.version = matches[2][0..49]
                  else
                    self.version = matches[2]
                  end
                end
                break
              end
            rescue Exception => e
              Rails.logger.warn("#{e} for generator pattern #{pattern} for generator: #{generator.id}")
            end
          end
        end
      end
    end
  end

  private

  def set_id
    if self.id == nil
      self.id = SecureRandom.uuid
    end
  end

  def initialise_for_saving
    if self.platform_id.blank?
      self.platform = Platform.default_platform
    end
  end
end
