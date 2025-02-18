class SystemsUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :systems_users, :id => false do |t|
      t.references :system, null: false, type: :string, limit: 36, foreign_key: true
      t.references :user, null: false, type: :string, limit: 36, foreign_key: true
      t.timestamps
    end
    add_index :systems_users, [:system_id, :user_id], unique: true
  end
end
