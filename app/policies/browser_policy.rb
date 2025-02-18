class BrowserPolicy < ApplicationPolicy
  def index?
    public_access_to_data?
  end
end
