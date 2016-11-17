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

	end

	def create

	end

	def show
		@subject_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: @subject.id)
		redirect_to conversation_path(@subject_conversation) if !@subject_conversation.blank?
	end

	def edit

	end

	def update

	end

	def destroy 

	end

end
