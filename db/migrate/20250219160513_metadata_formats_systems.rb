class MetadataFormatsSystems < ActiveRecord::Migration[8.0]
  def change
    create_table :metadata_formats_systems, :id => false do |t|
      t.references :system, null: false, type: :string, limit: 36, foreign_key: true
      t.references :metadata_format, null: false, type: :string, limit: 36, foreign_key: true
      t.timestamps
    end
    add_index :metadata_formats_systems, [:system_id, :metadata_format_id], unique: true
  end
end
