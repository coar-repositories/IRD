class UserPolicy < ApplicationPolicy

  def permitted_attributes
    if @user.has_role?(:administrator)
      [:email, :fore_name, :last_name, :access_revoked, role_ids: []]
    elsif @user.has_role?(:superuser)
      [:email, :fore_name, :last_name, :access_revoked]
    else
      [:fore_name, :last_name]
    end
  end

  def update_roles?
    User.valid_user?(@user)&& @user.has_role?(:administrator)
  end

  def generate_api_key?
    User.valid_user?(@user) && @user.has_role?(:api)
  end

  def dashboard?
    # User.valid_user?(@user) && (@user == current_user || @user.has_role?(:administrator))
    User.valid_user?(@user)
  end

  def autocomplete?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def index?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def show?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user == @record)
  end

  def update?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || (@user.has_role?(:superuser) && !@record.has_role?(:administrator)))
  end

  def create?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def destroy?
    (User.valid_user?(@user) && @user.has_role?(:administrator) || @user.has_role?(:superuser) && @user != @record) unless @record.has_role?(:administrator) # prevents users from deleting themselves or deleting admins
  end

  def inspect_user?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def revoke_access?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || (@user.has_role?(:superuser) && !@record.has_role?(:administrator)))
  end

  def restore_access?
    revoke_access?
  end
end