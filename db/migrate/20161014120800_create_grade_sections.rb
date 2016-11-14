class CreateGradeSections < ActiveRecord::Migration[5.0]
  def change
    create_table :grade_sections do |t|
		t.integer :institute_id
		t.integer :grade_id
		t.integer :section_id
		t.integer :classteacher_id
		t.integer :creator_id
		t.timestamps
    end

    add_index :grade_sections, :institute_id
    add_index :grade_sections, :grade_id
    add_index :grade_sections, :section_id
    add_index :grade_sections, :classteacher_id
    add_index :grade_sections, :creator_id 
  end
end
