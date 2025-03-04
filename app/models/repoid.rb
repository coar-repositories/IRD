class Repoid < ApplicationRecord
  include TranslateEnum

  enum :identifier_scheme, { ird: 0, opendoar: 1, re3data: 2, roar: 3, lyrasis: 4, oai: 5 }, prefix: true, default: :ird, scopes: true
  translate_enum :identifier_scheme

  belongs_to :system
  scope :third_party, -> { where.not(identifier_scheme: [0,5]) }

  def to_s
    "#{self.identifier_scheme}:#{self.identifier_value}"
  end

end
