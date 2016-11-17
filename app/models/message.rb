class Message < ApplicationRecord

	belongs_to :message_creator, class_name: "User", foreign_key: :creator_id ,inverse_of: :created_messages
	
	belongs_to :conversation, class_name: "Conversation", foreign_key: :conversation_id, inverse_of: :messages
	
	has_many :attachments, class_name: :Attachment, dependent: :destroy, as: :attachable
		
end
