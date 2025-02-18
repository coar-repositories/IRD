class AdminPolicy < ApplicationPolicy

  def authenticate_as?
    true
  end

  def index?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def job_control?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def perform_batch_operations?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

end
