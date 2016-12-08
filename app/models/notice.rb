class Notice < ApplicationRecord

	belongs_to :notice_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_notices

	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :notices, optional: true
	
	has_one :attachment, class_name: :Attachment, as: :attachable 

	def grade_section_models
		!self.grade_section_ids.blank? ? GradeSection.where(id: self.grade_section_ids.split(", ")) : []
	end

	def recipients
		!self.recipient_ids.blank? ? User.where(id: self.recipient_ids.split(", ")) : []
	end

	def can_user_edit_notice user
		if(user.role.include?("Principal") or user.role.include?("Institute Admin"))
			return true
		else
			return false	
		end
	end

end
