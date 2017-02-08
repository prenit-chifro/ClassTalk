class AttendanceRecord < ApplicationRecord

	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :attendance_records

	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :attendance_records

	belongs_to :section, class_name: :Section, foreign_key: :section_id, inverse_of: :attendance_records

	belongs_to :record_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_attendance_records

	def present_students
		if(!self.present_student_ids.blank?)
			return present_students = User.where(id: self.present_student_ids.split(", "))
		else
			return []	
		end
		
	end

	def absent_students
		institute = self.institute
		grade = self.grade
		section = self.section
		
		all_students = section.get_members_with_given_roles_for_institute_and_grade_with_role(institute, grade, ["Student"])
		present_students = self.present_students
		return absent_students = all_students - present_students
	end

end
