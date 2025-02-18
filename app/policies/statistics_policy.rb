# frozen_string_literal: true

class StatisticsPolicy < ApplicationPolicy

  def by_continent?
    index?
  end

  def by_country?
    index?
  end

  def by_platform?
    index?
  end

  def clear_cache?
    User.valid_user?(@user) && @user.has_role?(:administrator)
  end

  def index?
    User.valid_user?(@user) && @user.has_role?(:administrator)
    # false
  end

end
