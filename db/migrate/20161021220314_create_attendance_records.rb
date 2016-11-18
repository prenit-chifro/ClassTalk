class CreateAttendanceRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :attendance_records do |t|
    	t.integer :institute_id
      t.integer :grade_id
      t.integer :section_id
    	t.string :present_student_ids, default: ""
    	t.date :date
      t.integer :creator_id
      t.timestamps
    end

    add_index :attendance_records, :institute_id
    add_index :attendance_records, :grade_id
    add_index :attendance_records, :section_id
    add_index :attendance_records, :date
  end
end
