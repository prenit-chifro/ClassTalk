class InstituteGrade < ApplicationRecord
	
	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :institutes_grades
	
	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, inverse_of: :grades_institutes

	belongs_to :grade_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_institutes_grades, optional: true

end
