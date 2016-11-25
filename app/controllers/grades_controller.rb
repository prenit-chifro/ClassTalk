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
			@grade = current_user.teaching_sections_subjects_models.map(&:grade).uniq
		end
		if(current_user.role == "Principal" or current_user.role == "Institute Admin")
			@grades = @institute.grades
		end
	end	

	def new

	end

	def create

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
