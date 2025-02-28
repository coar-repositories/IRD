class Annotation < ApplicationRecord

  has_and_belongs_to_many :systems
  scope :unrestricted, -> { where(restricted: :false) }
end
