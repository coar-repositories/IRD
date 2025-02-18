class AnnotationsSystems < ActiveRecord::Migration[8.0]
  def change
    create_table :annotations_systems, :id => false do |t|
      t.references :annotation, null: false, foreign_key: true, type: :string, limit: 25
      t.references :system, null: false, foreign_key: true, type: :string, limit: 36
      t.timestamps
    end
    add_index :annotations_systems, [:annotation_id, :system_id], unique: true
  end
end
