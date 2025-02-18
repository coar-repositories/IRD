class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries, id: :string, limit: 10 do |t|
      t.string :name
      t.integer :continent

      t.timestamps
    end
    add_index :countries, :name, unique: true
    add_index :countries, :continent
  end
end
