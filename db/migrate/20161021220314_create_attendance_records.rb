class CreateAttendanceRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :attendance_records do |t|
    	t.integer :grade_section_id
    	t.string :present_student_ids, default: ""
    	t.date :date
      	t.timestamps
    end

    add_index :attendance_records, :grade_section_id
    add_index :attendance_records, :present_student_ids
    add_index :attendance_records, :date
  end
end
