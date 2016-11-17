class ConversationsController < ApplicationController
	before_action :set_conversation, except: [:index, :new, :create, :new_group, :add_new_member] 

	def set_conversation
		@conversation = Conversation.find_by(id: params[:id])
		if(@conversation.blank?)
			head :ok
			return
		end
	end

	def index
		@conversations = current_user.participating_conversations.order(updated_at: :desc)
		@groups = @conversations.map{|c| c if (c.is_group)}.compact
		
		@contacts = []
		@sections = current_user.sections
		@sections.each do |section|
			other_section_members = section.get_other_members_for_user(current_user)
			@contacts = @contacts + other_section_members
		end
		@contacts = @contacts.compact.uniq
		@unread_conversation_ids_array = []
		@conversations.each do |conversation|
			conversation_participant_model = conversation.get_conversation_participant_model_for_participant(current_user)
			unread_received_messages = conversation.messages.where("is_seen_by_all_participants != ? and created_at > ? and creator_id != ?", true, conversation_participant_model.created_at, current_user.id)
			unread_received_messages.each do |message|
				seen_user_ids_array = message.seen_user_ids.split(", ").map{|id| id.to_i}.uniq
				if(!seen_user_ids_array.include?(current_user.id))
					@unread_conversation_ids_array << conversation.id
					break
				end
			end
		end

		@assigned_classteacher_grades_sections_model = current_user.assigned_classteacher_grades_sections_models.first
		if(!@assigned_classteacher_grades_sections_model.blank?)
			@todays_attendance_record = @assigned_classteacher_grades_sections_model.attendance_records.find_by(date: Date.today)

			@institute = @assigned_classteacher_grades_sections_model.institute
			@grade = @assigned_classteacher_grades_sections_model.grade
			@section = @assigned_classteacher_grades_sections_model.section
			@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
		end
		
	end
	
	def new
		@contacts = []
		@sections = current_user.sections
		@sections.each do |section|
			other_section_members = section.get_other_members_for_user(current_user)
			@contacts = @contacts + other_section_members
		end
		@contacts = @contacts.compact.uniq
	end

	def send_request
		if(!params[:request_message].blank? and @conversation.can_user_send_message(current_user) == false)	
			
				if(@conversation.requestor_ids.blank?)
					@conversation.requestor_ids = current_user.id
				else
					@conversation.requestor_ids = @conversation.requestor_ids + ", #{current_user.id}"
				end
				@new_message = @conversation.messages.create(creator_id: current_user.id, content: params[:request_message], category: "Chat_Request")
				
				@new_attachment = @new_message.attachments.create(media: current_user.profile_picture.media)
				@conversation.update(updated_at: @new_message.created_at, last_message_id: @new_message.id)
				
				render "messages/create", layout: false
			
		end
	end

	def accept_request
		if(!params[:requestor_id].blank? and !params[:acceptor_id].blank?)
			@requestor = User.find_by(id: params[:requestor_id])
			if(@conversation.can_user_send_message(@requestor) == false)	
				
				@requestor = User.find_by(id: params[:requestor_id])
							
				if(@conversation.requestor_ids.include?(", #{@requestor.id}"))
					requestor_string = @conversation.requestor_ids.gsub(", #{@requestor.id}", "")
					requestor_string = "" if @conversation.requestor_ids.include?("#{@requestor.id}")
				else
					requestor_string = ""
				end
				@new_message = @conversation.messages.create(creator_id: @requestor.id, content: "Hey I accepted chat request from #{@requestor.first_name} #{@requestor.last_name}", category: "Request_Acceptance")
				@conversation.update(requestor_ids: requestor_string, updated_at: @new_message.created_at, last_message_id: @new_message.id)
				
				@request_messages = @conversation.messages.where(creator_id: @requestor.id, category: "Chat_Request")
				@request_messages.each do |message|
					@message = message
					render_to_string 'messages/destroy.js'
					message.destroy
				end
				
				render "messages/create", layout: false

			else
				@already_accepted = true
			end	
			
		end
	end
	
	def create
		
		if(!params[:participant_ids].blank?)
			@participants = User.where(id: params[:participant_ids]).to_a if !params[:participant_ids].blank?
			if(!@participants.blank?)
				if(params[:conversation_id].blank?)
						
					old_conversations = current_user.participating_conversations
			
					old_conversations.each do |conversation|
						if(conversation.is_custom_group == true and conversation.check_if_conversation_is_between_users(@participants + [current_user]))
							
							@conversation = conversation
							(@participants - @conversation.participants).each do |participant|
								@conversation.add_participant(participant.id, current_user.id)
							end
							redirect_to conversation_path(@conversation)
							return
						
						end
					end
					
					@conversation = current_user.created_conversations.create
					@participants.each do |participant|
						@conversation.add_participant(participant.id, current_user.id)	
					end
					redirect_to conversation_path(@conversation)
					
				else
					@conversation = current_user.participating_conversations.where(id: params[:conversation_id]).first
					if(!@conversation.blank?)
						if(!(@participants - @conversation.participants).blank?)
							(@participants - @conversation.participants).each do |new_participant|
								@conversation.add_participant(new_participant.id, current_user.id)
							end
							redirect_to conversation_path(@conversation), format: request.format
						else
							redirect_to conversation_path(@conversation)
							return
						end
					else
						
					end
				end				
			else
				
			end
		else
		
		end
		
	end

	def new_group
		if(request.get?)
			@contacts = []
			@sections = current_user.sections
			@sections.each do |section|
				other_section_members = section.get_other_members_for_user(current_user)
				@contacts = @contacts + other_section_members
			end
			@contacts = @contacts.compact.uniq
			render "new_group"

		elsif(request.post?) 
			if(!params[:conversation_name].blank?)
				new_conversation = current_user.created_conversations.create(conversation_name: params[:conversation_name])
				new_conversation.banner_image.update(media: params[:banner_image]) if !params[:banner_image].blank?
				if(!params[:participant_ids].blank?)
					participants = User.where(id: params[:participant_ids].split(","))
					participants.each do |participant|
						new_conversation.add_participant(participant.id, current_user.id)
					end
				end
				redirect_to conversation_path(new_conversation), format: :js	
			end
		end
			
	end

	def add_new_member
		@institutes = current_user.institutes
	end

	def show
		
		if(!@conversation.blank?)

			@conversation_participant_model = @conversation.get_conversation_participant_model_for_participant(current_user)
			@messages = @conversation.messages.where("created_at > ?", @conversation_participant_model.created_at).order(created_at: :desc)
			if(params[:page] and params[:page].to_i >= 2)
				
				if( !params[:message_category].blank? )
					if(params[:message_category] == "Messages")
						@Messages_category_messages = @messages.page(params[:page]).per(20).to_a.reverse!
						set_seen_status_to_recieved_messages(@Messages_category_messages)
						render "show", layout: false
						return
					end
					if(params[:message_category] == "Media")
						@Media_category_messages = Message.includes(:attachments).where.not(attachments: { attachable_id: nil }).where(id: @messages.map(&:id))
						@Media_category_messages = Kaminari.paginate_array(@Media_category_messages).page(params[:page]).per(20).to_a.reverse!
						set_seen_status_to_recieved_messages(@Media_category_messages)
						render "show", layout: false
						return
					end
					if(params[:message_category] == "Chat_Request")
						@Chat_Request_messages = @messages.where(category: "Chat_Request")
						@Chat_Request_messages = @Chat_Request_messages.page(params[:page]).per(20).to_a.reverse!
						set_seen_status_to_recieved_messages(@Messages_category_messages)
						render "show", layout: false
						return
					end				

					if(!@conversation.message_categories.blank? and @conversation.message_categories.include?(params[:message_category]))
						@conversation.message_categories.split(", ").each do |category|
							instance_variable_set("@" + category + "_messages", @messages.where(category: category))
							instance_variable_set("@" + category + "_messages", instance_variable_get("@" + category + "_messages").page(params[:page]).per(20).to_a.reverse!)
							set_seen_status_to_recieved_messages(instance_variable_get("@" + category + "_messages"))
						end
						
						render "show", layout: false
						return
					end
							
				end

			else 

				if(!@conversation.message_categories.blank?)
					@conversation.message_categories.split(", ").each do |category|
						instance_variable_set("@" + category + "_messages", @messages.where(category: category))
						instance_variable_set("@" + category + "_messages", Kaminari.paginate_array(instance_variable_get("@" + category + "_messages")).page(1).per(10))
						set_seen_status_to_recieved_messages(instance_variable_get("@" + category + "_messages"))
					end
					
				end
				@Chat_Request_messages = @messages.where(category: "Chat_Request")
				@Media_category_messages = Message.includes(:attachments).where.not(attachments: { attachable_id: nil }).where(id: @messages.map(&:id))

				@Messages_category_messages = @messages.page(1).per(20).to_a.reverse!
				@Media_category_messages = Kaminari.paginate_array(@Media_category_messages).page(1).per(10)
				@Chat_Request_messages = Kaminari.paginate_array(@Chat_Request_messages).page(1).per(10)
					
				set_seen_status_to_recieved_messages(@Messages_category_messages)
				set_seen_status_to_recieved_messages(@Media_category_messages)
			end
		end
	end
	
	def edit
		@conversation = Conversation.find_by(id: params[:id])
		if(!@conversation.blank?)
			@participants = @conversation.other_participants(current_user)
		end
		
	end

	def destroy 

	end

	def add_message_category
		if(!@conversation.blank? and !params[:message_category].blank?)
			if(!@conversation.message_categories.include?(params[:message_category]))
				if(@conversation.message_categories.blank?)
					@conversation.update(message_categories: params[:message_category])
				else
					@conversation.update(message_categories: @conversation.message_categories + ", #{params[:message_category]}")
				end
			end
		end	
	end

	def delete_message_category
		if(!@conversation.blank? and !params[:message_category].blank?)
			if(@conversation.message_categories.include?(params[:message_category]))
				if(@conversation.message_categories.include?(", #{params[:message_category]}"))
					@conversation.update(message_categories: @conversation.message_categories.gsub(", #{params[:message_category]}", ""))
				else
					@conversation.update(message_categories: "")
				end
			end
		end		
	end
	
	def set_seen_status_to_recieved_messages(messages)
		
		recieved_messages = []
		messages.each do |message|
			if(message.creator_id != current_user.id)
				recieved_messages << message
			end
		end
		
		recieved_messages.each do |message|
			if(!message.is_seen_by_all_participants)
				other_participant_ids_array = @conversation.participants.where.not(id: message.creator_id).map{|p| p.id}
				message.seen_user_ids = "" if message.seen_user_ids.blank? 

				seen_user_ids_array = message.seen_user_ids.split(", ").map{|id| id.to_i}.uniq
				if(seen_user_ids_array.blank? or !seen_user_ids_array.include?(current_user.id))
					seen_user_ids_array << current_user.id
					message.seen_user_ids = seen_user_ids_array.join(", ")
					message.save
					if(other_participant_ids_array.sort == seen_user_ids_array.sort)
						render_to_string_anywhere('messages/set_seen_status.js', {message: message, publish_to_message_creator: true})
						message.update(is_seen_by_all_participants: true)
					end
				end	
			end
			
		end
		
		@unread_conversation_ids_array.delete(@conversation.id) if !@unread_conversation_ids_array.blank?
	end
end
