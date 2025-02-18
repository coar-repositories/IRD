class DeduplicationPolicy < ApplicationPolicy
  def index?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def deduplicate?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

end
