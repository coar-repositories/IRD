class AddMediaTypesToSystem < ActiveRecord::Migration[8.0]
  def change
    add_column :systems, :media_types, :string, array: true
  end
end
