class Event < ApplicationRecord

	belongs_to :event_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_events

	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :events, optional: true
	
	def grade_section_models
		!self.grade_section_ids.blank? ? GradeSection.where(id: self.grade_section_ids.split(", ")) : []
	end

	def participants
		!self.participant_ids.blank? ? User.where(id: self.participant_ids.split(", ")) : []
	end


end
