class CreateSectionSubjects < ActiveRecord::Migration[5.0]
  def change
    create_table :section_subjects do |t|
		t.integer :institute_id
		t.integer :grade_id
		t.integer :section_id
		t.integer :subject_id
		t.integer :subject_teacher_id
		t.integer :creator_id
		t.timestamps
    end
    
    add_index :section_subjects, :institute_id
    add_index :section_subjects, :grade_id
    add_index :section_subjects, :section_id
    add_index :section_subjects, :subject_id
    add_index :section_subjects, :subject_teacher_id
    add_index :section_subjects, :creator_id
  end
end
