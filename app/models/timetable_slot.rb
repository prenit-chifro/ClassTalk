class TimetableSlot < ApplicationRecord
	
	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :timetable_slots

	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :timetable_slots

	belongs_to :section, class_name: :Section, foreign_key: :section_id, inverse_of: :timetable_slots

	belongs_to :subject, class_name: :Subject, foreign_key: :subject_id, inverse_of: :timetable_slots, optional: true

	belongs_to :teacher, class_name: :User, foreign_key: :teacher_id, inverse_of: :teaching_timetable_slots, optional: true

end
