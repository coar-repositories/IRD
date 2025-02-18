class OrganisationPolicy < ApplicationPolicy
  def index?
    public_access_to_data?
  end

  def systems?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_agent_for?(@record))
  end

  def search?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def autocomplete?
    public_access_to_data?
  end

  def add_user_as_agent?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def ownerships?
    systems?
  end

  def responsibilities?
    systems?
  end

  def responsible_parties?
    public_access_to_data?
  end

  def view_stats?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_agent_for?(@record))
  end

  def update?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def make_rp?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def make_rp_for_country?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def remove_rp_status?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end
end