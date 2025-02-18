class CreateNetworkChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :network_checks, id: :string, limit: 36 do |t|
      t.boolean :passed, default: false
      t.integer :network_check_type
      t.integer :http_code, null: true
      t.string :description
      t.references :system, null: false, foreign_key: true, type: :string, limit: 36
      t.integer :failures, default: 0 #number of consecutive failures
      t.datetime :error_at, default: nil

      t.timestamps
    end
    # add_index :network_checks, :passed
    # add_index :network_checks, :network_check_type
    add_index :network_checks, [:system_id, :network_check_type], unique: true
    # add_index :network_checks, :error_at
  end
end
