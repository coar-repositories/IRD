class AddDisabledFlagToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :access_revoked, :boolean, default: false
  end
end
