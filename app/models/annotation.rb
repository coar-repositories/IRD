class Annotation < ApplicationRecord

  before_create :set_id
  has_and_belongs_to_many :systems

  scope :unrestricted, -> { where(restricted: :false) }

  private

  def set_id
    if self.id == nil
      self.id = ActiveSupport::Inflector.parameterize(self.name)
    end
  end
end
