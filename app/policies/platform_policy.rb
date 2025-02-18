class PlatformPolicy < ApplicationPolicy
  def index?
    public_access_to_data?
  end
end