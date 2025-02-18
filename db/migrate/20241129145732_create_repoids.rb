class CreateRepoids < ActiveRecord::Migration[8.0]
  def change
    create_table :repoids do |t|
      t.integer :identifier_scheme, null: false
      t.string :identifier_value, null: false
      t.references :system, null: false, foreign_key: true, type: :string, limit: 36
    end
    add_index :repoids, :identifier_scheme
    add_index :repoids, :identifier_value
    add_index :repoids, [:identifier_scheme, :identifier_value, :system_id], unique: true
  end
end
