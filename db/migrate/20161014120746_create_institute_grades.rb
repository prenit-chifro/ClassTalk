class CreateInstituteGrades < ActiveRecord::Migration[5.0]
  def change
    create_table :institute_grades do |t|
		t.integer :institute_id
		t.integer :grade_id
		t.integer :creator_id
		t.timestamps
    end

    add_index :institute_grades, :institute_id
    add_index :institute_grades, :grade_id
    add_index :institute_grades, :creator_id
  end
end
