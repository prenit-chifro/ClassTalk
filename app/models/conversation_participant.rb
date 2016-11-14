class ConversationParticipant < ApplicationRecord
	
	belongs_to :conversation, class_name: "Conversation", inverse_of: :conversation_participant_models
	
	belongs_to :participant, class_name: "User", inverse_of: :participating_conversation_models

end
