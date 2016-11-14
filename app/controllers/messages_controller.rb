class MessagesController < ApplicationController
	def create
		@conversation = Conversation.find_by(id: params[:conversation_id])
		@new_message = @conversation.messages.create(content: params[:content], category: params[:message_category], creator_id: current_user.id)
		
		attached_files = params[:attached_files]
		if (!attached_files.blank?)
			attached_files.each do |file|
				new_attachment = @new_message.attachments.new()
				new_attachment.media = file

				if(!params[:attachment_category].blank?)
					new_attachment.category = params[:attachment_category] 
					if( "Image, Video, Link".include?(params[:attachment_category]) )
						@conversation.message_categories = "" if @conversation.message_categories.blank?
						if(!@conversation.message_categories.include?(params[:message_category]))
							@new_message.update(category: "Media")	
						end
					else	
						@new_message.update(category: params[:attachment_category])	if @new_message.category != params[:attachment_category]
					end	
				end

				new_attachment.save
			end
		end
		
		@conversation.update_attributes(updated_at: @new_message.created_at, last_message_id: @new_message.id)

		#publish_message_on_android_notification(@new_message, @conversation)
	end

	def set_seen_user_id
		message_id = params[:id]
		message = Message.find_by(id: message_id)
		@publish_to_message_creator = false
		if(!message.blank?)
			other_participant_ids_array = message.conversation.participants.where.not(id: message.creator_id).map{|p| p.id}
			message.seen_user_ids = "" if message.seen_user_ids.blank?
			seen_user_ids_array = message.seen_user_ids.split(", ").map{|id| id.to_i}.uniq
			if(seen_user_ids_array.blank? or !seen_user_ids_array.include?(current_user.id))
				seen_user_ids_array << current_user.id
				message.seen_user_ids = seen_user_ids_array.join(", ")
				
				if(other_participant_ids_array.sort == seen_user_ids_array.sort)
					message.is_seen_by_all_participants = true
					@publish_to_message_creator = true
				end
				message.save
			end
			
		else
		
		end
		
		render partial: "messages/set_seen_status.js", locals: {message: message, publish_to_message_creator: @publish_to_message_creator}		
	end

end
