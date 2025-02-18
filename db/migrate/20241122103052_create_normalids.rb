class CreateNormalids < ActiveRecord::Migration[8.0]
  def change
    create_table :normalids do |t|
      t.string :url, null: false
      t.string :domain
      t.references :system, null: false, foreign_key: true, type: :string, limit: 36

      t.timestamps
    end
  end
end
