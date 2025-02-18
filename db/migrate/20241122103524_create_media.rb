class CreateMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :media, id: :string, limit: 50 do |t|
      t.string :name
      t.string :uri

      t.timestamps
    end
    # add_index :media, :name
    # add_index :media, :uri
  end
end
