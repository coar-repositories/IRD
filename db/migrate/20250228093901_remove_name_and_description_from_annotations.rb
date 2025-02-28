class RemoveNameAndDescriptionFromAnnotations < ActiveRecord::Migration[8.0]
  def change
    remove_column :annotations, :name
    remove_column :annotations, :description
  end
end
