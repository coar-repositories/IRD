class AddGeneratorPatternToPlatforms < ActiveRecord::Migration[8.0]
  def change
    add_column :platforms, :generator_patterns, :string, array: true
  end
end
