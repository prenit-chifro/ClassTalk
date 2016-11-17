class SectionMember < ApplicationRecord
	
	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :institutes_sections_members_models

	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :grades_sections_members_models
	
	belongs_to :section, class_name: :Section, foreign_key: :section_id, inverse_of: :sections_grades
	
	belongs_to :member, class_name: :User, foreign_key: :member_id, inverse_of: :members_sections
	
	belongs_to :membership_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_sections_members_models, optional: true

end
