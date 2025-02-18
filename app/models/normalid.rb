class Normalid < ApplicationRecord
  include Curation
  belongs_to :system

  validates :url, presence: true
  validates :url, uniqueness: { scope: :system_id}

  before_save :update_domain

  private

  def update_domain
    self.domain = Utilities::UrlUtility.get_domain_from_normalid(self.url)
  end

end
