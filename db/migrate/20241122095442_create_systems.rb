class CreateSystems < ActiveRecord::Migration[8.0]
  def change
    create_table :systems, id: :string, limit: 36 do |t|
      t.string :name
      t.string :aliases, array: true
      t.string :short_name
      t.string :url
      t.text :description
      t.integer :system_status, default: 0
      t.integer :oai_status, default: 0
      t.references :platform, null: false, foreign_key: true, type: :string, limit: 100
      t.string :platform_version
      t.integer :record_status, default: 0
      t.string :record_source, limit: 50
      t.references :owner, null: true, foreign_key: { to_table: 'organisations' }, type: :string, limit: 36
      t.references :rp, null: true, foreign_key: { to_table: 'organisations' }, type: :string, limit: 36
      t.references :country, null: true, foreign_key: true, type: :string, limit: 100
      t.references :generator, null: true, foreign_key: true, type: :string, limit: 36
      t.string :contact
      t.integer :random_id, null: false, default: 0
      t.json :metadata, default: {}
      t.json :formats, default: {}
      t.integer :system_category, default: 0
      t.integer :subcategory, default: 0
      t.json :issues, default: {}
      t.integer :primary_subject, default: 0
      t.string :oai_base_url, null: true
      t.datetime :reviewed, null: true

      t.timestamps
    end
    #### REMOVED INDEXES FROM DB WHERE THEY ARE NOT USED (BECAUSE USED IN OPEN-SEARCH INDEX INSTEAD)
    # add_index :systems, :name
    add_index :systems, :system_status
    # add_index :systems, :primary_subject
    add_index :systems, :oai_status
    # add_index :systems, :subcategory
    # add_index :systems, :system_category
    add_index :systems, :record_status
    # add_index :systems, :oai_base_url
    add_index :systems, :reviewed
  end
end
