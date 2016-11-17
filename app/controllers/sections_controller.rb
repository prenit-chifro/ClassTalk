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

	end

	def create
		
	end

	def show
		@section_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id)
		redirect_to conversation_path(@section_conversation) if !@section_conversation.blank?
	end

	def edit

	end

	def update

	end

	def destroy 

	end

end
