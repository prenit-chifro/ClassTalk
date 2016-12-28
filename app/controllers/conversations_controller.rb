class ConversationsController < ApplicationController
	before_action :set_conversation, except: [:index, :new, :create, :new_group, :add_new_member, :homework] 

	def set_conversation
		@conversation = Conversation.find_by(id: params[:id])
		if(@conversation.blank?)
			head :ok
			return
		end
	end

	def index
		@conversations = current_user.participating_conversations.order(updated_at: :desc)
			
		inbox_conversations_array = []
		@conversations.each do |conversation|
			if(conversation.is_group != true and !conversation.messages.last.blank? and conversation.messages.last.creator_id != current_user.id)	
				inbox_conversations_array << conversation
			end
		end

		@sent_conversations = current_user.participating_conversations.where(creator_id: current_user.id).order(updated_at: :desc)
	 	sent_conversations_array = []
	 	@sent_conversations.each do |conversation|
			if((!conversation.messages.last.blank? and conversation.messages.last.creator_id == current_user.id and conversation.is_group == false) or (conversation.last_message_id.blank? and conversation.creator_id == current_user.id and conversation.is_group == false)) 
				sent_conversations_array << conversation
			end
		end

		group_conversations_array = []
		@conversations.each do |conversation|
			if(conversation.is_group == true)
				group_conversations_array << conversation
			end	
		end
		
		@homework_conversations = @conversations.where("message_categories LIKE ?", "HomeWork%")
		homework_messages_array = []

		if(current_user.role.include?("Teacher"))
			if(!@homework_conversations.blank?)
				@homework_conversations.each do |conversation|					
				    conversation_homework_messages = conversation.messages.where(category: "HomeWork", creator_id: current_user.id).order(created_at: :desc)
					if(!conversation_homework_messages.blank?)
						conversation_homework_messages.each do |message|
							homework_messages_array << message
						end	
					end
				end
	    	end
	    else
	    	if(!@homework_conversations.blank?)
				@homework_conversations.each do |conversation|					
				    conversation_homework_messages = conversation.messages.where(category: "HomeWork").order(created_at: :desc)
					if(!conversation_homework_messages.blank?)
						conversation_homework_messages.each do |message|
							homework_messages_array << message
						end	
					end
				end
	    	end	
		end

		@inbox_conversations = Conversation.where(id: inbox_conversations_array.map(&:id)).order(updated_at: :desc)
		@sent_conversations = Conversation.where(id: sent_conversations_array.map(&:id)).order(updated_at: :desc)
		@group_conversations = Conversation.where(id: group_conversations_array.map(&:id)).order(updated_at: :desc)

		@unread_conversation_ids_array = []
		@inbox_conversations.each do |conversation|
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
		@unread_group_conversation_ids_array = []
		@group_conversations.each do |conversation|
			conversation_participant_model = conversation.get_conversation_participant_model_for_participant(current_user)
			unread_received_messages = conversation.messages.where("is_seen_by_all_participants != ? and created_at > ? and creator_id != ?", true, conversation_participant_model.created_at, current_user.id)
			unread_received_messages.each do |message|
				seen_user_ids_array = message.seen_user_ids.split(", ").map{|id| id.to_i}.uniq
				if(!seen_user_ids_array.include?(current_user.id))
					@unread_group_conversation_ids_array << conversation.id
					break
				end
			end
		end

		
		if(params[:page] and params[:page].to_i >= 2)
			@inbox_conversations = @inbox_conversations.page(params[:page]).per(10)
			@sent_conversations = @sent_conversations.page(params[:page]).per(10)
			@group_conversations = @group_conversations.page(params[:page]).per(10)
			@homework_messages = Message.where(id: homework_messages_array.map(&:id)).page(params[:page]).per(10)
		else
			@inbox_conversations = @inbox_conversations.page(1).per(10)
			@sent_conversations = @sent_conversations.page(1).per(10)
			@group_conversations = @group_conversations.page(1).per(10)
			@homework_messages = Message.where(id: homework_messages_array.map(&:id)).page(1).per(10)
		end
		
		@principals = @institute.get_members_with_given_roles(["Principal"])
		@admins = @institute.get_members_with_given_roles(["Institute Admin"])
		@teachers = @institute.get_members_with_given_roles(["Teacher"])

		if(current_user.role.include?("Principal") or current_user.role.include?("Institute Admin")) 
			
			@grades = @institute.grades
			@institutes_grades_sections_models = @institute.institutes_grades_sections_models

            @teachers = @institute.get_members_with_given_roles(["Teacher"]) 
                
			render "admin_index" 
			return

		end

		if(current_user.role.include?("Teacher"))
			@all_section_member_models = current_user.members_sections
			@grades = @all_section_member_models.map(&:grade).uniq
			@assigned_classteacher_grades_sections_model = current_user.assigned_classteacher_grades_sections_models.first
			if(!@assigned_classteacher_grades_sections_model.blank?)
				@todays_attendance_record = current_user.created_attendance_records.find_by(date: Date.today)

				@grade = @assigned_classteacher_grades_sections_model.grade
				@section = @assigned_classteacher_grades_sections_model.section
				@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
			end

			render "teacher_index"
			return
		end

		if(current_user.role == "Student" or current_user.role == "Parent")
			@all_section_member_models = current_user.members_sections
			@grades = @all_section_member_models.map(&:grade).uniq
			
			render "student_index"
			return
		end
	end
	
	def new
		@principals = @institute.get_members_with_given_roles(["Principal"])
		@admins = @institute.get_members_with_given_roles(["Institute Admin"])
		@teachers = @institute.get_members_with_given_roles(["Teacher"])
		if(current_user.role.include?("Principal") or current_user.role.include?("Institute Admin"))			
			@institutes_grades_sections_models = @institute.institutes_grades_sections_models
		end

		if(current_user.role == "Teacher")
			@teaching_section_subject_models = current_user.teaching_sections_subjects_models
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
							
						end
					end
					if(@conversation.blank?)
						@conversation = current_user.created_conversations.create
						@participants.each do |participant|
							@conversation.add_participant(participant.id, current_user.id)	
						end	
					end

					if(!params[:message].blank? or !params[:attached_files].blank?)
						@new_message = @conversation.messages.create(content: params[:message], category: params[:message_category], creator_id: current_user.id)
		
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
						@conversation.update_attributes(last_message_id: @new_message.id)
						render_to_string "messages/create.js"
					end

					redirect_to conversation_path(@conversation), format: :js
					
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
			@principals = @institute.get_members_with_given_roles(["Principal"])
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
			
			render "new_group"

		elsif(request.post?) 
			if(!params[:conversation_name].blank?)
				@conversation = current_user.created_conversations.create(conversation_name: params[:conversation_name], is_open_group: params[:is_open_group])
				@conversation.banner_image.update(media: params[:banner_image]) if !params[:banner_image].blank?
				if(params[:is_open_group] == "false" and !params[:admin_ids].blank?)
					group_admins = User.where(id: params[:admin_ids])
					
					group_admins.each do |group_admin|
						@conversation.add_participant(group_admin.id, current_user.id, true)
					end
				end
				
				@principals = @institute.get_members_with_given_roles(["Principal"])
				@admins = @institute.get_members_with_given_roles(["Institute Admin"])
				@teachers = @institute.get_members_with_given_roles(["Teacher"])
				
				if(current_user.role == "Institute Admin")
					@institutes_grades_sections_models = @institute.institutes_grades_sections_models
				end

				if(current_user.role == "Teacher")
					@teaching_section_subject_models = current_user.teaching_sections_subjects_models
				end
				
				redirect_to new_conversation_path(conversation_id: @conversation.id), format: :js
				
			end
		end
			
	end

	def add_new_member
		@institutes = current_user.institutes
	end

	def show
		
		if(!@conversation.blank?)
			if(@conversation.is_institute_conversation)
				@institute = Institute.find_by(id: @conversation.institute_id)
				
				@contacts = @institute.get_members_with_given_roles(["Principal", "Institute Admin"])
				@teachers = @institute.get_members_with_given_roles(["Teacher"])
				@students = @institute.get_members_with_given_roles(["Student"])
				@parents = @institute.get_members_with_given_roles(["Parent"])
			end

			if(@conversation.is_section_conversation)
				@institute = Institute.find_by(id: @conversation.institute_id)
				@grade = Grade.find_by(id: @conversation.grade_id)
				@section = Section.find_by(id: @conversation.section_id)
				
				@classteacher = @section.get_classteacher_for_institute_and_grade(@institute, @grade)
				@section_subject_models = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
				@students = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Student"])
				@parents = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Parent"])
			end

			if(@conversation.is_subject_conversation)
				@institute = Institute.find_by(id: @conversation.institute_id)
				@grade = Grade.find_by(id: @conversation.grade_id)
				@section = Section.find_by(id: @conversation.section_id)
				@subject = Subject.find_by(id: @conversation.subject_id)

				@subjectteacher = @section.get_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, @subject)
				@students = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Student"])
				@parents = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Parent"])
			end

			@conversation_participant_model = @conversation.get_conversation_participant_model_for_participant(current_user)
			
			if(params[:page] and params[:page].to_i >= 2)
				
				@Media_category_messages = @conversation.messages.order(created_at: :desc).includes(:attachments).where.not(attachments: { attachable_id: nil }).page(params[:page]).per(10)
				@Messages_category_messages = @conversation.messages.where("created_at >= ?", @conversation_participant_model.created_at).where.not(id: @Media_category_messages.map(&:id)).order(created_at: :desc).page(params[:page]).per(10)

				set_seen_status_to_recieved_messages(@Messages_category_messages)
				set_seen_status_to_recieved_messages(@Media_category_messages)

				if(!@conversation.message_categories.blank?)
					@conversation.message_categories.split(", ").each do |category|
						instance_variable_set("@" + category.split(" ").join("_") + "_messages", @conversation.messages.where("created_at >= ?", @conversation_participant_model.created_at).where(category: category).order(created_at: :desc).page(params[:page]).per(10))
						
						set_seen_status_to_recieved_messages(instance_variable_get("@" + category.split(" ").join("_") + "_messages"))
					end
					
				end
			else 
				
				@Media_category_messages = @conversation.messages.order(created_at: :desc).includes(:attachments).where.not(attachments: { attachable_id: nil }).page(1).per(10)
				@Messages_category_messages = @conversation.messages.where("created_at >= ?", @conversation_participant_model.created_at).where.not(id: @Media_category_messages.map(&:id)).order(created_at: :desc).page(1).per(10)

				set_seen_status_to_recieved_messages(@Messages_category_messages)
				set_seen_status_to_recieved_messages(@Media_category_messages)

				if(!@conversation.message_categories.blank?)
					@conversation.message_categories.split(", ").each do |category|
						instance_variable_set("@" + category.split(" ").join("_") + "_messages", @conversation.messages.where("created_at >= ?", @conversation_participant_model.created_at).where(category: category).order(created_at: :desc).page(1).per(10))
						
						set_seen_status_to_recieved_messages(instance_variable_get("@" + category.split(" ").join("_") + "_messages"))
					end
					
				end
					
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
				other_participant_ids_array = message.conversation.participants.where.not(id: message.creator_id).map{|p| p.id}
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

	def homework

		@homework_conversations = current_user.participating_conversations.where("message_categories LIKE ?", "HomeWork%").order(updated_at: :desc)
		homework_messages_array = []

		if(current_user.role == "Teacher")
			if(!@homework_conversations.blank?)
				@homework_conversations.each do |conversation|					
				    conversation_homework_messages = conversation.messages.where(category: "HomeWork", creator_id: current_user.id).order(created_at: :desc)
					if(!conversation_homework_messages.blank?)
						conversation_homework_messages.each do |message|
							homework_messages_array << message
						end	
					end
				end
	    	end
	    else
	    	if(!@homework_conversations.blank?)
				@homework_conversations.each do |conversation|					
				    conversation_homework_messages = conversation.messages.where(category: "HomeWork").order(created_at: :desc)
					if(!conversation_homework_messages.blank?)
						conversation_homework_messages.each do |message|
							homework_messages_array << message
						end	
					end
				end
	    	end
	
		end
	    
	    if(!params[:page].blank? and params[:page].to_i >= 2)
	    	@homework_messages = Message.where(id: homework_messages_array.map(&:id)).page(params[:page]).per(10)
	    else
	    	@homework_messages = Message.where(id: homework_messages_array.map(&:id)).page(1).per(10)
	    end
	    
 	end
end
