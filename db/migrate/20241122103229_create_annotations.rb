class CreateAnnotations < ActiveRecord::Migration[8.0]
  def change
    create_table :annotations, id: :string, limit: 25 do |t|
      t.string :name
      t.string :description
      t.boolean :restricted, default: false
      t.timestamps
    end
    add_index :annotations, :restricted
  end
end
