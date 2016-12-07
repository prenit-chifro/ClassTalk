class SectionsController < ApplicationController

	before_action :set_institute
	def set_institute
		@institute = Institute.find_by(id: params[:institute_id])
	end

	before_action :set_grade
	def set_grade
		@grade = Grade.find_by(id: params[:grade_id])
	end

	before_action :set_section, except: [:index, :new, :create]
	def set_section
		@section = Section.find_by(id: params[:id])
	end

	def index

	end

	def new
		@grades_sections_models = @grade.grades_sections.where(institute_id: @institute.id)
		@sections = Section.where.not(id: @grades_sections_models.map(&:section_id))
		@teachers = @institute.get_members_with_given_roles(["Teacher"])
	end

	def create
		if(!params[:step].blank? and params[:step].to_i == 1)
			if(!params[:section_ids].blank?)
			  @grade_section_models = []
	          params[:section_ids].each do |section_id, section_extras|
	            
	          	section = Section.find_by(id: section_id)
              	grade_section_model = @institute.institutes_grades_sections_models.create(grade_id: @grade.id, section_id: section.id, creator_id: current_user.id) if !@grade.blank? and !section.blank?
              	@grade_section_models << grade_section_model
              	@section_conversation = current_user.created_conversations.create(conversation_name: "Class #{@grade.grade_name}#{section.section_name}".truncate(20), institute_id: @institute.id, grade_id: @grade.id, section_id: section.id, message_categories: "HomeWork", is_custom_group: false) if !@grade.blank? and !section.blank?

	            @teachers = @institute.get_members_with_given_roles(["Teacher"])
	            @subjects = Subject.all
	            
	          end
	        
	        end 
	        render "add_new_section_step_1.js"   
		end
		if(!params[:step].blank? and params[:step].to_i == 2)
			if(!params[:section_ids].blank?)
              params[:section_ids].each do |section_id, section_extras|
                section = Section.find_by(id: section_id)
                @section_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: section.id, subject_id: nil)
                if(!section_extras[:subject_ids].blank?)
              		section_extras[:subject_ids].each do |subject_id, subject_extras|
	                    subject = Subject.find_by(id: subject_id)
	                    @institute.institutes_sections_subjects_models.create(institute_id: @institute.id, grade_id: @grade.id, section_id: section.id, subject_id: subject.id, creator_id: current_user.id) if !@grade.blank? and !section.blank? and !subject.blank?
	                    @subject_conversation = current_user.created_conversations.create(conversation_name: "#{subject.subject_name}, #{grade.grade_name}#{section.section_name}".truncate(20), institute_id: @institute.id, grade_id: @grade.id, section_id: section.id, subject_id: subject.id, message_categories: "HomeWork", is_custom_group: false) if !@grade.blank? and !section.blank? and !subject.blank?
	                    if(!subject_extras[:subject_teacher_id].blank?)
	                    	subject_teacher = User.find_by(id: subject_extras[:subject_teacher_id])
	                    	section.add_member_for_institute_and_grade(@institute, @grade, current_user, subject_teacher, "Teacher")
	                    	section.set_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, subject, subject_teacher) if !subject_teacher.blank?
	                    	@subject_conversation.add_participant(subject_teacher.id, current_user.id, true) if !subject_teacher.blank?  
	                    	@section_conversation.add_participant(subject_teacher.id, current_user.id, true) if !@section_conversation.blank? and !subject_teacher.blank?
	                    end
	                    
	             	end
	            end      
              end
             	
            end
            render "add_new_section.js"
		end
	end

	def show
		
		if(!@section.blank?)
			@section_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id)
			@classteacher = @section.get_classteacher_for_institute_and_grade(@institute, @grade)
			@section_subject_models = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
			@students = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Student"])
			@parents = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Parent"])
		end
		#redirect_to conversation_path(@section_conversation) if !@section_conversation.blank?
	end

	def edit

	end

	def update

	end

	def destroy 

	end

	def set_classteacher
		if(request.get?)
			@classteacher = @section.get_classteacher_for_institute_and_grade(@institute, @grade)
			@teachers = @institute.get_members_with_given_roles(["Teacher"])
			render "set_classteacher.html", layout: false if request.xhr?
		elsif(request.post?)
			@classteacher = User.find_by(id: params[:classteacher_id])
			if(!@classteacher.blank?)
				@section.add_member_for_institute_and_grade(@institute, @grade, current_user, @classteacher, "Teacher")
				@section.set_classteacher_for_institute_and_grade(@institute, @grade, @classteacher) 
				@section_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: nil)
				@section_conversation.add_participant(@classteacher.id, current_user.id, true) if !@section_conversation.blank? and !@classteacher.blank?				

				respond_to do |format|
					format.html {redirect_to institute_grade_section_path(@institute, @grade, @section)}
					format.js {render "set_classteacher.js", layout: false}	
				end
			end
			
		end

	end

end
