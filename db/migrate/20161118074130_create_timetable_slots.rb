class CreateTimetableSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :timetable_slots do |t|
    	t.integer :institute_id
    	t.integer :grade_id
    	t.integer :section_id
    	t.integer :creator_id
    	t.date :date
    	t.time :start_time
    	t.time :end_time
    	t.integer :subject_id
    	t.integer :teacher_id
      	t.timestamps
    end
  end
end
