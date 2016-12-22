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
		
		if(!message.blank?)
			other_participant_ids_array = message.conversation.participants.where.not(id: message.creator_id).map{|p| p.id}
			message.seen_user_ids = "" if message.seen_user_ids.blank?
			seen_user_ids_array = message.seen_user_ids.split(", ").map{|id| id.to_i}.uniq
			if(seen_user_ids_array.blank? or !seen_user_ids_array.include?(current_user.id))
				seen_user_ids_array << current_user.id
				message.seen_user_ids = seen_user_ids_array.join(", ")
				
				if(other_participant_ids_array.sort == seen_user_ids_array.sort)
					message.is_seen_by_all_participants = true
				end
				message.save
			end
			
		else
		
		end
		
		render partial: "messages/set_seen_status.js", locals: {message: message}		
	end

	def set_acted_user_ids
		message_id = params[:id]
		@message = Message.find_by(id: message_id)
		@conversation = @message.conversation
		acted_user_ids = params[:acted_user_ids]
		
		if(!@message.blank? and !@conversation.message_categories.blank? and @conversation.message_categories.include?(@message.category))
			student_participant_ids_array = @conversation.participants.where.not(id: @message.creator_id).where(role: "Student").map{|p| p.id.to_s}
			@message.acted_user_ids = "" if @message.acted_user_ids.blank?
			acted_user_ids_array = @message.acted_user_ids.split(", ").map{|id| id.to_s}.uniq
			if(!acted_user_ids.blank?)
				acted_user_ids.each do |acted_user_id|
					if(acted_user_ids_array.blank? or !acted_user_ids_array.include?(acted_user_id))
						acted_user_ids_array << acted_user_id
						@message.acted_user_ids = acted_user_ids_array.join(", ")
						
						
						
					end
							
				end
				if(student_participant_ids_array.sort == acted_user_ids_array.sort)
					@message.is_acted_by_all_participants = true
				end
				@message.save
			end
			
			
		else
		
		end
		
		render partial: "messages/set_acted_status.js", locals: {message: @message}		
	end

	def seen_by_users
		@conversation = Conversation.find_by(id: params[:conversation_id])
		@message = @conversation.messages.find_by(id: params[:id])
		@message.seen_user_ids = "" if @message.seen_user_ids.blank?
		@seen_user_ids = @message.seen_user_ids.split(", ")
		@seen_users = User.where(id: @seen_user_ids)
		render "seen_by_users"
	end

	def acted_by_users
		@conversation = Conversation.find_by(id: params[:conversation_id])
		@message = @conversation.messages.find_by(id: params[:id])
		@message.acted_user_ids = "" if @message.acted_user_ids.blank?
		acted_user_ids = @message.acted_user_ids
		acted_user_ids_array = acted_user_ids.split(", ")
		@acted_users = User.where(id: acted_user_ids_array)
		student_participant_ids_array = @conversation.participants.where.not(id: @message.creator_id).where(role: "Student").map{|p| p.id.to_s}
		pending_user_ids_array = student_participant_ids_array - acted_user_ids_array
		@pending_users = User.where(id: pending_user_ids_array)

		render "acted_by_users"
	end

end
