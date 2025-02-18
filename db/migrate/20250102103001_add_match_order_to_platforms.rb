class AddMatchOrderToPlatforms < ActiveRecord::Migration[8.0]
  def change
    add_column :platforms, :match_order, :float, default: 100.0
    add_index :platforms, :match_order
  end
end
