class AddMatchersToPlatforms < ActiveRecord::Migration[8.0]
  def change
    add_column :platforms, :matchers, :string, array: true
  end
end
