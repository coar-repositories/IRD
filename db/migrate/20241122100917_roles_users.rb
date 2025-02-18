class RolesUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :roles_users, :id => false do |t|
      t.references :role, null: false, type: :string, limit: 30, foreign_key: true
      t.references :user, null: false, type: :string, limit: 36, foreign_key: true
      t.timestamps
    end
    add_index :roles_users, [:role_id, :user_id], unique: true #prevents adding user to role twice
  end
end
