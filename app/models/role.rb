class Role < ApplicationRecord
  include MachineReadability
  has_and_belongs_to_many :users, :join_table => 'roles_users'

  before_create :set_id

  def self.machine_readable_attributes
    Default_machine_readable_attributes
  end

  private

  def set_id
    if self.id == nil
      self.id = ActiveSupport::Inflector.parameterize(self.name)
    end
  end
end
