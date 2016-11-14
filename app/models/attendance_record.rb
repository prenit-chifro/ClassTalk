class AttendanceRecord < ApplicationRecord

	belongs_to :grade_section, class_name: :GradeSection, foreign_key: :grade_section_id, inverse_of: :attendance_records


end
