class CreateOrganisations < ActiveRecord::Migration[8.0]
  def change
    create_table :organisations, id: :string, limit: 36 do |t|
      t.string :name
      t.string :aliases, array: true
      t.string :short_name
      t.string :ror
      t.string :location
      t.decimal :latitude, :precision => 10, :scale => 6
      t.decimal :longitude, :precision => 10, :scale => 6
      t.references :country, null: false, foreign_key: true, type: :string, limit: 10
      t.string :website
      t.string :domain
      t.boolean :rp, default: false

      t.timestamps
    end
    # add_index :organisations, :name
    add_index :organisations, :ror
    add_index :organisations, :rp
    add_index :organisations, :domain
    # add_index :organisations, :aliases, using: :gin
  end
end
