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
		@grades = current_user.members_sections.map{|m| m.grade}.uniq
	end

	def new

	end

	def create

	end

	def show
		@grade_section_models = @grade.grades_sections.where(institute_id: @institute.id)
	end

	def edit

	end

	def update

	end

	def destroy 

	end

end
