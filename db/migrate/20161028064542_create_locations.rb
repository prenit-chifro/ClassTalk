class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
    	t.float :latitude
    	t.float :longitude
    	t.string :address
    	t.references :locatable, polymorphic: true, index: true
	    t.timestamps
    end

    add_index :locations, :latitude
    add_index :locations, :longitude
  end
end
