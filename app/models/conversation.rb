class Conversation < ApplicationRecord
	
	belongs_to :conversation_creator, class_name: "User", foreign_key: :creator_id, inverse_of: :created_conversations
	
	has_many :participants, class_name: "User", through: :conversation_participant_models, source: :participant
	
	has_many :conversation_participant_models, class_name: "ConversationParticipant", foreign_key: :conversation_id, inverse_of: :conversation, dependent: :destroy
	
	has_many :messages, class_name: "Message", foreign_key: :conversation_id, inverse_of: :conversation, dependent: :destroy

	has_one :banner_image, class_name: :Attachment, dependent: :destroy, as: :attachable

	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, optional: true

	belongs_to :grade, class_name: :Grade, foreign_key: :grade_id, optional: true

	belongs_to :section, class_name: :Section, foreign_key: :grade_id, optional: true

	belongs_to :subject, class_name: :Subject, foreign_key: :subject_id, optional: true
	
	accepts_nested_attributes_for :banner_image

	def last_message
		self.messages.find_by(id: self.last_message_id)
	end

	def is_group
		if(self.is_custom_group == false)
			return true
		else
			return self.conversation_participant_models.length > 2
		end
		
	end

	def can_user_view_messages user
		if(self.check_if_participant(user.id))
			if("Principal, Institute Admin, Teacher".include?(user.role))
				return true
			else
				if(self.is_custom_group)
					return !self.requestor_ids.include?(user.id.to_s)
				else
					return false
				end
			end	
		else
			return false
		end
		
	end

	def can_user_send_message user
		if(self.check_if_participant(user.id))
			if(user.role.include?("Principal") or user.role.include?("Institute Admin"))
				return true
			else
				if(self.is_custom_group)
					if(self.is_open_group)
						return true
					else
						conversation_participant_model = self.get_conversation_participant_model_for_participant(user)
						if(!conversation_participant_model.blank?)	
							return conversation_participant_model.is_admin 
						else
							return false
						end
					end
					
				else
					if(user.role.include?("Teacher"))
						return true
					else	
						return false
					end
					
				end
			end	
		else
			return false
		end
		
	end

	def can_user_send_request user
		if(self.check_if_participant(user.id))
			if("Principal, Institute Admin, Teacher".include?(user.role))
				return true
			else
				if(self.is_custom_group == true)
					if(self.requestor_ids.include?(user.id.to_s))
						if(self.messages.where(creator_id: user.id, category: "Chat_Request").length <=3)
							return true
						else
							return false
						end
					else
						return false
					end
				else
					return false
				end
			end	
		else
			return false
		end	
	end

	def can_user_add_participants user
		if(self.check_if_participant(user.id))
			if("Principal, Institute Admin, Teacher".include?(user.role))
				return true
			else
				if(self.is_custom_group)
					return !self.requestor_ids.include?(user.id.to_s)
				else
					return false
				end
				
			end	
		else
			return false
		end
		
	end

	def check_if_participant user_id
		self.participants.map(&:id).include?(user_id)
	end
	
	def add_participant participant_id, participant_adder_id, is_admin=false
		if(!check_if_participant(participant_id))
			self.conversation_participant_models.create(participant_id: participant_id, participant_adder_id: participant_adder_id, is_admin: is_admin)
		end
	end
		
	def institute
		Institute.find_by(id: self.institute_id)
	end	

	def grade
		Grade.find_by(id: self.grade_id)
	end

	def section
		Section.find_by(id: self.section_id)
	end

	def is_subject_conversation 
		if(!self.is_custom_group and !self.subject_id.blank?)
			return true
		else
			return false
		end
	end

	def is_section_conversation 
		if(!self.is_custom_group and self.subject_id.blank? and !self.section_id.blank?)
			return true
		else
			return false
		end
	end

	def is_institute_conversation 
		if(!self.is_custom_group and self.subject_id.blank? and self.section_id.blank? and !self.institute_id.blank?)	
			return true
		else
			return false
		end
	end

	def other_participants user
		if(self.is_custom_group == false)
			if(user.role == "Parent" or user.role == "Student")
				return self.participants.where.not(role: ["Student", "Parent"], id: user.id)
			end
		end

		return self.participants.where.not(id: user.id) 
		
	end
	
	def get_conversation_participant_model_for_participant participant
		return self.conversation_participant_models.find_by(participant_id: participant.id)
	end
	
	def check_if_conversation_is_between_users users
		participants = self.participants
		if(participants.map{|p| p.id }.uniq.sort == users.map{|u| u.id}.uniq.sort)
			return true
		end
		
		return false
	end
	
	def get_conversation_name_to_show_to_user user
		if(self.conversation_name.blank?)
			if(self.participants.length == 2)
				return self.conversation_name if !self.conversation_name.blank?
				self.other_participants(user).first.first_name.capitalize if !self.other_participants(user).first.blank?
			else
				name = "You"
				self.other_participants(user).first(1).each do |participant|
					name = name + ", #{participant.first_name}"
				end
				other_length = (self.other_participants(user).length) - 2
				name = name + " and #{other_length} other" if other_length > 1
				name
			end
		else
			self.conversation_name
		end	
	end

	def get_conversation_image_url_to_show_to_user user, style
		if(self.banner_image.blank?)
			if(self.participants.length == 2)
				self.other_participants(user).first.profile_picture.media.url(style)
			else
				self.other_participants(user).first.profile_picture.media.url(style)
			end
			
		else
			self.banner_image.media.url(style)
		end	
	end

	def get_url_for_banner_image_for_user user
		if(!self.is_group and self.participants.length == 2)
			"/users/#{self.other_participants(user).first.id}"
		else
			"/conversations/#{self.id}"
		end
		
	end
	
	after_create :create_banner_image_for_conversation
	
	def create_banner_image_for_conversation
		if(self.banner_image.blank?)
			self.create_banner_image(category: :conversation_banner_image, media: self.conversation_creator.profile_picture.media)
		end
	end

	after_create :add_creators_participant_model

	def add_creators_participant_model
		self.add_participant(self.creator_id, self.creator_id, true)
	end
	
end
