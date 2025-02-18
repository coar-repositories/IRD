class MediaSystems < ActiveRecord::Migration[8.0]
  def change
    create_table :media_systems, :id => false do |t|
      t.references :medium,  null: false, foreign_key: {to_table: :media}, type: :string, limit: 50
      t.references :system, null: false, foreign_key: true, type: :string, limit: 36
      t.timestamps
    end
    add_index :media_systems, [:medium_id, :system_id], unique: true
  end
end
