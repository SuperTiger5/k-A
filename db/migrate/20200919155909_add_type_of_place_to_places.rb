class AddTypeOfPlaceToPlaces < ActiveRecord::Migration[5.1]
  def change
    add_column :places, :type_of_place, :string
  end
end
