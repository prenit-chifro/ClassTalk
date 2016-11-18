class Grade < ApplicationRecord
	
	has_many :institutes, class_name: :Institute, through: :grades_institutes, source: :institute
	
	has_many :grades_institutes, class_name: :InstituteGrade, foreign_key: :grade_id, inverse_of: :grade, dependent: :destroy
	
	has_many :sections, class_name: :Section, through: :grades_sections, source: :section
	
	has_many :grades_sections, class_name: :GradeSection, foreign_key: :grade_id, inverse_of: :grade, dependent: :destroy
	
	has_many :grades_sections_members_models, class_name: :SectionMember, foreign_key: :grade_id, inverse_of: :grade, dependent: :destroy

	has_many :grades_sections_subjects_models, class_name: :SectionSubject, foreign_key: :grade_id, inverse_of: :grade, dependent: :destroy

	has_many :attendance_records, class_name: :AttendanceRecord, foreign_key: :grade_id, inverse_of: :grade

	def get_sections_for_institute institute
		Section.where(id: self.grades_sections.where(institute_id: institute.id).map(&:section_id))
	end
	
	def get_grade_creator_for_institute institute
		self.grades_institutes.find_by(institute_id: institute.id).grade_creator
	end
	
end
