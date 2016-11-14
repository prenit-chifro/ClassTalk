class CreateInstituteMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :institute_members do |t|
		t.integer :institute_id
		t.integer :member_id
		t.string :role_in_institute
		t.string :child_ids
		t.integer :father_id
		t.integer :mother_id
		t.integer :creator_id
		t.timestamps
    end

    add_index :institute_members, :institute_id 
    add_index :institute_members, :member_id
    add_index :institute_members, :role_in_institute
    add_index :institute_members, :child_ids
    add_index :institute_members, :father_id
    add_index :institute_members, :mother_id
    add_index :institute_members, :creator_id
  end
end
