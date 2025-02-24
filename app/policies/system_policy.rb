class SystemPolicy < ApplicationPolicy

  def show?
    @record.published? || (User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record)))
  end

  def suggest_new_system?
    User.valid_user?(@user)
  end

  def access_unpublished_records?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def admin?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def process_as_duplicate?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def annotate?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def tag?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def mark_reviewed?
    update?
    # User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def publish?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_responsible_for?(@record))
  end

  def archive?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def make_draft?
    # User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_responsible_for?(@record))
    # User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def change_record_status_to_under_review?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record))
  end

  def add_repo_id?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def search?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def network_check?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def auto_curate?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def check_url?
    curate?
  end

  def check_oai_pmh_identify?
    curate?
  end

  def check_oai_pmh_formats?
    curate?
  end

  def get_thumbnail?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def remove_thumbnail?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def flag_as_defunct?
    update?
  end

  def curate?
    update?
  end

  def authorise_user?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.is_responsible_for?(@record))
  end

  def change_record_status?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def change_system_status?
    curate?
  end

  def change_oai_status?
    curate?
  end

  def change_rp?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser))
  end

  def autocomplete?
    public_access_to_data?
  end

  def update?
    User.valid_user?(@user) && (@user.has_role?(:administrator) || @user.has_role?(:superuser) || @user.can_curate?(@record))
  end

end