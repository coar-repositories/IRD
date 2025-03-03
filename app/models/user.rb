class User < ApplicationRecord
  include MachineReadability
  passwordless_with :email
  has_secure_password :api_key, validations: false

  # searchkick
  #
  # def search_data
  #   {
  #     name: display_name,
  #     email: email
  #   }
  # end

  has_and_belongs_to_many :roles, :join_table => 'roles_users'
  has_and_belongs_to_many :systems, :join_table => 'systems_users'
  has_and_belongs_to_many :organisations, :join_table => 'organisations_users'

  before_create :set_id

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, :fore_name, :last_name, presence: true


  Machine_readable_attributes = MachineReadableAttributeSet.new([
                                                                  MachineReadableAttribute.new(:id, "entity.id"),
                                                                  MachineReadableAttribute.new(:last_name, "entity.last_name"),
                                                                  MachineReadableAttribute.new(:fore_name, "entity.fore_name"),
                                                                  MachineReadableAttribute.new(:email, "entity.email"),
                                                                  MachineReadableAttribute.new(:created_at, "entity.created_at"),
                                                                  MachineReadableAttribute.new(:updated_at, "entity.updated_at")
                                                                ])

  def self.machine_readable_attributes
    Machine_readable_attributes
  end

  def self.valid_user?(user)
    true unless user == nil || user.access_revoked?
  end

  # def self.search(term)
  #   where("email LIKE ?", "%#{term}%").order('email')
  # end

  def display_name
    "#{fore_name} #{last_name}"
  end

  def name
    display_name
  end

  def access_revoked?
    self.access_revoked
  end

  def revoke_access!
    self.access_revoked = true
    self.save!
  end

  def restore_access!
    self.access_revoked = false
    self.save!
  end

  def has_role?(role_sym)
    roles.any? { |r| r.id.to_sym == role_sym }
  end

  def is_agent_for?(organisation)
    if organisation
      organisations.exists?(organisation.id)
    else
      false
    end
  end

  def is_responsible_for?(system)
    if system
      if system.rp
        return organisations.exists?(system.rp.id)
      end
    else
      false
    end
  end

  def can_curate?(system)
    if system
      if systems.exists?(system.id)
        return true
      else
        return is_responsible_for?(system)
      end
    end
    false
  end

  # will return un-digested key - this is the only time this will be available
  def generate_and_return_api_key
    new_key = SecureRandom.uuid
    self.api_key = new_key
    self.save!
    new_key
  end

  private

  def set_id
    self.id = SecureRandom.uuid if self.id.nil?
    self.api_key = SecureRandom.uuid if self.api_key.nil?
  end

end
