class AttendanceRecordsController < ApplicationController

	before_action :set_grade_section

	def set_grade_section
		@grade_section = GradeSection.find_by(id: params[:grade_section_id])
		head :ok and return if @grade_section.blank?
	end 

	def index

	end

	def new

	end

	def create
		if(!params[:present_student_ids].blank?)
			@institute = @grade_section.institute
			@grade = @grade_section.grade
			@section = @grade_section.section
			@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")

			@todays_attendance_record = @grade_section.attendance_records.find_by(date: Date.today) 
			if(@todays_attendance_record.blank?)
				@todays_attendance_record = @grade_section.attendance_records.create(present_student_ids: params[:present_student_ids].join(", "), date: Date.today)
			else
				@todays_attendance_record.update(present_student_ids: params[:present_student_ids].join(", "))
				
			end
			
		else	

		end
	end

	def show

	end

	def edit

	end

	def destroy

	end

end
