class CreateSectionMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :section_members do |t|
		t.integer :institute_id
		t.integer :grade_id
		t.integer :section_id
		t.integer :member_id
		t.integer :creator_id
		t.string :member_role
		t.timestamps
    end

    add_index :section_members, :institute_id
    add_index :section_members, :grade_id    
    add_index :section_members, :section_id
    add_index :section_members, :member_id
    add_index :section_members, :member_role
    add_index :section_members, :creator_id
  end
end
