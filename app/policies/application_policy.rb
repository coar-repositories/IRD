# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def admin?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def superuser?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def public_access_to_data?
    (ENV.fetch("PREVENT_PUBLIC_ACCESS_TO_DATA","false") != "true") || User.valid_user?(@user)
  end

  def download_json?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.has_role?(:downloader))
  end

  def download_csv?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.has_role?(:downloader))
  end

  def systems?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def index?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def show?
    public_access_to_data?
  end

  def create?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def new?
    create?
  end

  def update?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def edit?
    update?
  end

  def destroy?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
