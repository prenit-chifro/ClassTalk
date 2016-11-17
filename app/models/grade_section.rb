class GradeSection < ApplicationRecord
	
	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :institutes_grades_sections_models
	
	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :grades_sections
	
	belongs_to :section, class_name: :Section, foreign_key: :section_id, inverse_of: :sections_grades
	
	belongs_to :classteacher, class_name: :User, foreign_key: :classteacher_id, inverse_of: :assigned_classteacher_grades_sections_models, optional: true
	
	belongs_to :section_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_grade_sections_models, optional: true

	has_many :attendance_records, class_name: :AttendanceRecord, foreign_key: :grade_section_id, inverse_of: :grade_section, dependent: :destroy

	def events 
		Event.where("grade_section_ids like ?", "%#{self.id}%")
	end

	def notices
		Notice.where("grade_section_ids like ?", "%#{self.id}%")
	end

	after_create :add_creator_as_section_member

	def add_creator_as_section_member
		self.section.sections_members.create(institute_id: self.institute_id, grade_id: self.grade_id, member_id: self.creator_id, member_role: self.section_creator.role, creator_id: self.creator_id)
	end

end
