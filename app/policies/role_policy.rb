class RolePolicy < ApplicationPolicy

  def users?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def destroy?
    false
  end
end