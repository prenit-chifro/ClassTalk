class GradesController < ApplicationController

	before_action :set_institute
	def set_institute
		@institute = Institute.find_by(id: params[:institute_id])
	end

	before_action :set_grade, except: [:index, :new, :create]
	def set_grade
		@grade = Grade.find_by(id: params[:id])
	end

	def index
		if(current_user.role == "Student" or current_user.role == "Parent")
			@grades = current_user.members_sections.map{|m| m.grade}.uniq
		end
		if(@current_user.role == "Teacher")
			@grades = current_user.teaching_sections_subjects_models.map(&:grade).uniq
		end
		if(current_user.role == "Principal" or current_user.role == "Institute Admin")
			@grades = @institute.grades
		end
	end	

	def new
		@grades = Grade.where.not(id: @institute.grades.map(&:id))
		@sections = Section.all
	end

	def create
		if(!params[:step].blank? and params[:step].to_i == 1)
			if(!params[:grade_ids].blank?)
			  @grade_section_models = []
	          params[:grade_ids].each do |grade_id, grade_extras|
	            grade = Grade.find_by(id: grade_id)
	            custom_name = ""
	            if(!params[:grade_ids_for_grade_name].blank?)
	            	if(!params[:grade_ids_for_grade_name][grade_id].blank?)
	            		custom_name = params[:grade_ids_for_grade_name][grade_id][:grade_name]
	            	end
	            end
	            @institute.institutes_grades.create(custom_grade_name: custom_name, grade_id: grade.id, creator_id: current_user.id) if !grade.blank?
	          end


	          if(!params[:grade_ids_for_section].blank?)
	          	params[:grade_ids_for_section].each do |grade_id, grade_extras|
	          	  grade = Grade.find_by(id: grade_id)	
	          	  if(!grade_extras[:section_ids].blank?)
	          	  	grade_extras[:section_ids].each do |section_id|
	          	  	  section = Section.find_by(id: section_id)
		              grade_section_model = @institute.institutes_grades_sections_models.create(grade_id: grade.id, section_id: section.id, creator_id: current_user.id) if !grade.blank? and !section.blank?
		              @grade_section_models << grade_section_model
		              section_conversation = current_user.created_conversations.create(conversation_name: "#{grade.custom_name_for_institute(@institute)} #{section.section_name}".truncate(30), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, message_categories: "Homework", is_custom_group: false) if !grade.blank? and !section.blank?

	          	  	end	
	          	  end
	          	end
	          end
	          @teachers = @institute.get_members_with_given_roles(["Teacher"])
              @subjects = Subject.all
              render "add_new_class_step_1.js"	
	        end    
		end
		if(!params[:step].blank? and params[:step].to_i == 2)
			if(!params[:grade_ids_for_class_teacher].blank?)
              params[:grade_ids_for_class_teacher].each do |grade_id, grade_extras|
                grade = Grade.find_by(id: grade_id)
                if(!grade_extras[:section_ids_for_class_teacher].blank?)
                	grade_extras[:section_ids_for_class_teacher].each do |section_id, section_extras|
                		section = Section.find_by(id: section_id)
                		if(!section_extras[:classteacher_id].blank?)
                			classteacher = User.find_by(id: section_extras[:classteacher_id])
                			section.add_member_for_institute_and_grade(@institute, grade, current_user, classteacher, "Teacher")
		                  	section.set_classteacher_for_institute_and_grade(@institute, grade, classteacher) if !classteacher.blank?
		                  	section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) 
			                section_conversation.add_participant(classteacher.id, current_user.id) if !section_conversation.blank?

                		end	
                	end
                end
              end  
            end
             
            if(!params[:grade_ids_for_subject].blank?)
              params[:grade_ids_for_subject].each do |grade_id, grade_extras|
                
                if(!grade_extras[:section_ids_for_subject].blank?)
                	grade_extras[:section_ids_for_subject].each do |section_id, section_extras|

                		if(!section_extras[:subject_ids].blank?)
                			section_extras[:subject_ids].each do |subject_id|
                				grade = Grade.find_by(id: grade_id)
                				section = Section.find_by(id: section_id)
                				subject = Subject.find_by(id: subject_id)
			                    @institute.institutes_sections_subjects_models.create(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, creator_id: current_user.id) if !grade.blank? and !section.blank? and !subject.blank?
			                    subject_conversation = current_user.created_conversations.create(conversation_name: "#{subject.subject_name}, #{grade.custom_name_for_institute(@institute)} #{section.section_name}}".truncate(30), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, message_categories: "Homework", is_custom_group: false) if !grade.blank? and !section.blank? and !subject.blank?
			                    
                			end
                		end	
                	end
                end
              end  
            end

            if(!params[:grade_ids_for_subject_teacher].blank?)
              params[:grade_ids_for_subject_teacher].each do |grade_id, grade_extras|
                grade = Grade.find_by(id: grade_id)
                if(!grade_extras[:section_ids_for_subject_teacher].blank?)
                	grade_extras[:section_ids_for_subject_teacher].each do |section_id, section_extras|
                		section = Section.find_by(id: section_id)
                		if(!section_extras[:subject_ids_for_subject_teacher].blank?)
                			section_extras[:subject_ids_for_subject_teacher].each do |subject_id, subject_extras|
                				subject = Subject.find_by(id: subject_id)
                				if(!subject_extras[:subject_teacher_id].blank?)
                					subject_teacher = User.find_by(id: subject_extras[:subject_teacher_id])
			                    	section.add_member_for_institute_and_grade(@institute, grade, current_user, subject_teacher, "Teacher")
			                    	section.set_subject_teacher_for_institute_and_grade_and_subject(@institute, grade, subject, subject_teacher) if !subject_teacher.blank?
			                    	subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, is_custom_group: false) 
			                    	subject_conversation.add_participant(subject_teacher.id, current_user.id) if !subject_teacher.blank?  
			                    	section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) 
			                    	section_conversation.add_participant(subject_teacher.id, current_user.id) if !section_conversation.blank? and !subject_teacher.blank?  
                				end
                			end
                		end	
                	end
                end
              end 
            end

            redirect_to institute_path(@institute) + "#all-classes", format: :js
		end
		
	end

	def show
		if(current_user.role == "Student" or current_user.role == "Parent")
			@section_member_models = current_user.members_sections
			@grade_section_models = @grade.grades_sections.where(institute_id: @institute.id, section_id: @section_member_models.map(&:section_id))
		end
		if(@current_user.role == "Teacher")
			@teaching_section_subject_models = current_user.teaching_sections_subjects_models
			@grade_section_models = @grade.grades_sections.where(institute_id: @institute.id, section_id: @teaching_section_subject_models.map(&:section_id))
		end
		if(current_user.role == "Principal" or current_user.role == "Institute Admin")
			@grade_section_models = @grade.grades_sections.where(institute_id: @institute.id)
		end

		
	end

	def edit

	end

	def update

	end

	def destroy 

	end

end
