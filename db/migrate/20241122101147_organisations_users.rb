class OrganisationsUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :organisations_users, :id => false do |t|
      t.references :organisation, null: false, foreign_key: true, type: :string, limit: 36
      t.references :user, null: false, foreign_key: true, type: :string, limit: 36
      t.timestamps
    end
    add_index :organisations_users, [:organisation_id, :user_id], unique: true
  end
end
