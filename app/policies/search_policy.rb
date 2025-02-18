class SearchPolicy < ApplicationPolicy
  def index?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end
end
