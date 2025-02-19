class CreateMetadataFormats < ActiveRecord::Migration[8.0]
  def change
    create_table :metadata_formats, id: :string, limit: 36 do |t|
      t.string :name
      t.string :canonical_schema
      t.string :matchers, array: true
      t.float :match_order, default: 100.0

      t.timestamps
    end
    add_index :metadata_formats, :match_order
  end
end
