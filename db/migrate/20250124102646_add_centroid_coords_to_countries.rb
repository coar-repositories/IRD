class AddCentroidCoordsToCountries < ActiveRecord::Migration[8.0]
  def change
    add_column :countries, :longitude, :decimal, :precision => 10, :scale => 6
    add_column :countries, :latitude, :decimal, :precision => 10, :scale => 6
  end
end
