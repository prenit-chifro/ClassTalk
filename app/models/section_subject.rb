class SectionSubject < ApplicationRecord

	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :institutes_sections_subjects_models
	
	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :grades_sections_subjects_models
	
	belongs_to :section, class_name: :Section, foreign_key: :section_id, inverse_of: :sections_subjects
	
	belongs_to :subject, class_name: :Subject, foreign_key: :subject_id, inverse_of: :subjects_sections
	
	belongs_to :subject_teacher, class_name: :User, foreign_key: :subject_teacher_id, inverse_of: :teaching_sections_subjects_models, optional: true

	belongs_to :subject_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_sections_subjects_models, optional: true
	
end
