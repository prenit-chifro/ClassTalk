class CreateInstitutes < ActiveRecord::Migration[5.0]
  def change
    create_table :institutes do |t|
		t.string :institute_name
		t.integer :creator_id
		t.string :unique_institute_code
		t.timestamps
    end

    add_index :institutes, :institute_name
    add_index :institutes, :creator_id
    add_index :institutes, :unique_institute_code
  end
end
