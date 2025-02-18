class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles, id: :string, limit: 30 do |t|
      t.string :name, limit: 30
      t.string :description

      t.timestamps
    end
  end
end
