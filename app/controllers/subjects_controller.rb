class SubjectsController < ApplicationController

	before_action :set_institute
	def set_institute
		@institute = Institute.find_by(id: params[:institute_id])
	end

	before_action :set_grade
	def set_grade
		@grade = Grade.find_by(id: params[:grade_id])
	end

	before_action :set_section
	def set_section
		@section = Section.find_by(id: params[:section_id])
	end

	before_action :set_subject, except: [:index, :new, :create]
	def set_subject
		@subject = Subject.find_by(id: params[:id])	
	end

	def index

	end

	def new
		@section_subject_models = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
		@subjects = Subject.where.not(id: @section_subject_models.map(&:subject_id))
		@teachers = @institute.get_members_with_given_roles(["Teacher"])
	end

	def create
		if(!params[:subject_ids].blank?)
		  @section_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: nil)
          params[:subject_ids].each do |subject_id, subject_extras|
            
          	subject = Subject.find_by(id: subject_id)
            @institute.institutes_sections_subjects_models.create(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: subject.id, creator_id: current_user.id) if !@grade.blank? and !@section.blank? and !subject.blank?
            @subject_conversation = current_user.created_conversations.create(conversation_name: "#{subject.subject_name}, #{@grade.grade_name}#{@section.section_name}".truncate(20), institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: subject.id, message_categories: "HomeWork", is_custom_group: false) if !@grade.blank? and !@section.blank? and !subject.blank?
            if(!subject_extras[:subject_teacher_id].blank?)
            	subject_teacher = User.find_by(id: subject_extras[:subject_teacher_id])
            	@section.set_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, subject, subject_teacher) if !subject_teacher.blank?
            	@subject_conversation.add_participant(subject_teacher.id, current_user.id) if !subject_teacher.blank?  
            	@section_conversation.add_participant(subject_teacher.id, current_user.id) if !@section_conversation.blank? and !subject_teacher.blank?
            end
            
          end
        
        end 
        render "create.js"   
	end

	def show
		@subjectteacher = @section.get_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, @subject)
		@students = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Student"])
		@parents = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Parent"])
		@subject_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: @subject.id)
		#redirect_to conversation_path(@subject_conversation) if !@subject_conversation.blank?
	end

	def edit

	end

	def update

	end

	def destroy 

	end

end
