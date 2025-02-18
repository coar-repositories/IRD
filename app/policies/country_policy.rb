class CountryPolicy < ApplicationPolicy
  def index?
    public_access_to_data?
  end

  def geometries?
    true
  end

  def destroy?
    false
  end
end