class AddApiKeyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :api_key_digest, :string
    add_index :users, :api_key_digest, unique: true
  end
end
