class Subject < ApplicationRecord
	
	has_many :sections, class_name: :Section, through: :subjects_sections, source: :section
	
	has_many :subjects_sections, class_name: :SectionSubject, foreign_key: :subject_id, inverse_of: :subject, dependent: :destroy

	has_many :timetable_slots, class_name: :TimetableSlot, foreign_key: :subject_id, inverse_of: :subject, dependent: :destroy

	def get_subject_teacher_for_institute_and_grade_and_section institute, grade, section
		self.subjects_sections.find_by(institute_id: institute.id, grade_id: grade.id, section_id: section.id).subject_teacher
	end
	
	def get_subject_creator_for_institute_and_grade_and_section institute, grade, section
		self.subjects_sections.find_by(institute_id: institute.id, grade_id: grade.id, section_id: section.id).subject_creator
	end
		
end
