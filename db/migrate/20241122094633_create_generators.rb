class CreateGenerators < ActiveRecord::Migration[8.0]
  def change
    create_table :generators, id: :string, limit: 36 do |t|
      t.string :name
      t.references :platform, null: false, foreign_key: true, type: :string, limit: 100
      t.string :version, limit: 50

      t.timestamps
    end
    add_index :generators, :name, unique: true
  end
end
