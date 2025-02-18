class CreatePlatforms < ActiveRecord::Migration[8.0]
  def change
    create_table :platforms, id: :string, limit: 100 do |t|
      t.string :name
      t.string :url
      t.boolean :trusted, default: false
      t.boolean :oai_support, default: false
      t.string :oai_suffix, null: true

      t.timestamps
    end
    add_index :platforms, :oai_support
  end
end
