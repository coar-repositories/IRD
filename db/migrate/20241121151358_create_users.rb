class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :string, limit: 36 do |t|
      t.string :email, null: false
      t.string :fore_name
      t.string :last_name
      t.boolean :verified, default: false
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
