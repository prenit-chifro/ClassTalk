class ConversationsController < ApplicationController
	before_action :set_conversation, except: [:index, :new, :create, :new_group, :add_new_member, :my_classwork] 

	def set_conversation
		@conversation = Conversation.find_by(id: params[:id])
		if(@conversation.blank?)
			head :ok
			return
		end
	end

	def index
		@conversations = current_user.participating_conversations.order(updated_at: :desc)
		@sent_conversations = @conversations.where(creator_id: current_user.id)
		
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

		if(current_user.role == "Principal")
			@institute = current_user.institutes.first
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
		end

		if(current_user.role == "Institute Admin")
			@institute = current_user.institutes.first
			
			@principal = @institute.get_members_with_given_roles(["Principal"])
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
			@grades = @institute.grades
			@institutes_grades_sections_models = @institute.institutes_grades_sections_models
			
			if(params[:start_date].blank?)
				params[:start_date] = Date.today
			else
				params[:start_date] = Date.parse(params[:start_date])	
			end
			if(params[:end_date].blank?)
				params[:end_date] = Date.today
			else
				params[:end_date] = Date.parse(params[:end_date])	
			end

			@all_section_member_models = current_user.members_sections
			if(!@all_section_member_models.blank?)
				if(params[:grade_id].blank?)
					params[:grade_id] = @all_section_member_models.first.grade_id
				end
				if(params[:section_id].blank?)
					params[:section_id] = @all_section_member_models.first.section_id
				end
				@all_attendance_records = @institute.attendance_records.where("date >= ? AND date <= ?", params[:start_date], params[:end_date])
				if(@all_attendance_records.blank?)
					
					params[:start_date] = Date.yesterday
					
					@all_attendance_records = @institute.attendance_records.where("date >= ? AND date <= ?", params[:start_date], params[:end_date])
				end
				@all_students = @institute.get_members_with_given_roles(["Student"])

				@total_all_students = @all_students.count * @all_attendance_records.count
				@total_all_present_students = 0
				@all_attendance_records.each do |record|
					@total_all_present_students = @total_all_present_students + record.present_student_ids.split(", ").count
				end
				@total_all_absent_students = @total_all_students - @total_all_present_students

				@grade = Grade.find_by(id: params[:grade_id])
				@section = Section.find_by(id: params[:section_id])
				
				@section_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
				@section_attendance_records = @all_attendance_records.where(grade_id: @grade.id, section_id: @section.id)
				
				@total_section_students = @section_students.count * @section_attendance_records.count
				@total_section_present_students = 0
				@section_attendance_records.each do |record|
					@total_section_present_students = @total_section_present_students + record.present_student_ids.split(", ").count
				end
				@total_section_absent_students = @total_section_students - @total_section_present_students

				@institutes_grade_section_models = @institute.institutes_grades_sections_models
                @teachers = @institute.get_members_with_given_roles(["Teacher"]) 
                @notices = Notice.where(institute_id: @institute.id).order(updated_at: :desc).page(1).per(10)
			end

			render "admin_index"
		end

		if(current_user.role == "Teacher")
			@principal = @institute.get_members_with_given_roles(["Principal"])
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
			@teaching_section_subject_models = current_user.teaching_sections_subjects_models

			@assigned_classteacher_grades_sections_model = current_user.assigned_classteacher_grades_sections_models.first
			if(!@assigned_classteacher_grades_sections_model.blank?)
				@todays_attendance_record = current_user.created_attendance_records.find_by(date: Date.today)

				@institute = @assigned_classteacher_grades_sections_model.institute
				@grade = @assigned_classteacher_grades_sections_model.grade
				@section = @assigned_classteacher_grades_sections_model.section
				@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
			end

		end

		if(current_user.role == "Student" or current_user.role == "Parent")
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
		end
	end
	
	def new
		if(current_user.role == "Principal")
			@institute = current_user.institutes.first
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
		end

		if(current_user.role == "Institute Admin")
			@institute = current_user.institutes.first
			
			@principal = @institute.get_members_with_given_roles(["Principal"])
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
			@institutes_grades_sections_models = @institute.institutes_grades_sections_models
			
		end

		if(current_user.role == "Teacher")
			@principal = @institute.get_members_with_given_roles(["Principal"])
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
			@teaching_section_subject_models = current_user.teaching_sections_subjects_models

			@assigned_classteacher_grades_sections_model = current_user.assigned_classteacher_grades_sections_models.first
			if(!@assigned_classteacher_grades_sections_model.blank?)
				@todays_attendance_record = current_user.created_attendance_records.find_by(date: Date.today)

				@institute = @assigned_classteacher_grades_sections_model.institute
				@grade = @assigned_classteacher_grades_sections_model.grade
				@section = @assigned_classteacher_grades_sections_model.section
				@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
			end

		end

		if(current_user.role == "Student" or current_user.role == "Parent")
			@admins = @institute.get_members_with_given_roles(["Institute Admin"])
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
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
			if(current_user.role == "Principal")
				@institute = current_user.institutes.first
				@admins = @institute.get_members_with_given_roles(["Institute Admin"])
				@teachers = @institute.get_members_with_given_roles(["Teacher"])
			end

			if(current_user.role == "Institute Admin")
				@institute = current_user.institutes.first
				
				@principal = @institute.get_members_with_given_roles(["Principal"])
				@admins = @institute.get_members_with_given_roles(["Institute Admin"])
				@teachers = @institute.get_members_with_given_roles(["Teacher"])
				@institutes_grades_sections_models = @institute.institutes_grades_sections_models
				
			end

			if(current_user.role == "Teacher")
				@principal = @institute.get_members_with_given_roles(["Principal"])
				@admins = @institute.get_members_with_given_roles(["Institute Admin"])
				@teachers = @institute.get_members_with_given_roles(["Teacher"])
				@teaching_section_subject_models = current_user.teaching_sections_subjects_models

				@assigned_classteacher_grades_sections_model = current_user.assigned_classteacher_grades_sections_models.first
				if(!@assigned_classteacher_grades_sections_model.blank?)
					@todays_attendance_record = current_user.created_attendance_records.find_by(date: Date.today)

					@institute = @assigned_classteacher_grades_sections_model.institute
					@grade = @assigned_classteacher_grades_sections_model.grade
					@section = @assigned_classteacher_grades_sections_model.section
					@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
				end

			end

			if(current_user.role == "Student" or current_user.role == "Parent")
				@admins = @institute.get_members_with_given_roles(["Institute Admin"])
				@teachers = @institute.get_members_with_given_roles(["Teacher"])
			end
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
				@section_subject_models = @section.sections_subjects.where(institute_id: @institute.id)
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
			@messages = @conversation.messages.where("created_at >= ?", @conversation_participant_model.created_at).order(created_at: :desc)
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
						instance_variable_set("@" + category + "_messages", @messages.where(category: category).page(1).per(10))
						
						set_seen_status_to_recieved_messages(instance_variable_get("@" + category + "_messages"))
					end
					
				end
				
				@Media_category_messages = Message.includes(:attachments).where.not(attachments: { attachable_id: nil }).where(id: @messages.map(&:id)).page(1).per(10)

				@Messages_category_messages = @messages.page(1).per(10)				
					
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

	def my_classwork
	    @participating_conversations = current_user.participating_conversations
	    @message_categories_array = []
	    if(!@participating_conversations.blank?)
	      @participating_conversations.each do |conversation|
	        conversation.message_categories = "" if conversation.message_categories.blank?
	        conversation_message_categories_array = conversation.message_categories.split(", ")
	        conversation_message_categories_array.each do |category|
	            if(!@message_categories_array.include?(category))
	                @message_categories_array << category
	            end

	            conversation_participant_model = conversation.get_conversation_participant_model_for_participant(current_user)
				messages = conversation.messages.where("created_at >= ?", conversation_participant_model.created_at).order(created_at: :desc)
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

					
					if(instance_variable_get("@" + category + "_messages").blank?)
						instance_variable_set("@" + category + "_messages", messages.where(category: category).page(1).per(10))
					else
						instance_variable_set("@" + category + "_messages", instance_variable_get("@" + category + "_messages") + messages.where(category: category).page(1).per(10))
						set_seen_status_to_recieved_messages(messages.where(category: category).page(1).per(10))
					end
					
					Rails.logger.debug instance_variable_get("@" + category + "_messages").inspect
			
				end
	        end
	        
	      end


	    end


 	end
end
