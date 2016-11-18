class AttendanceRecord < ApplicationRecord

	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :attendance_records

	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :attendance_records

	belongs_to :section, class_name: :Section, foreign_key: :section_id, inverse_of: :attendance_records

	belongs_to :record_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_attendance_records

end
