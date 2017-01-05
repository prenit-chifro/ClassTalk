class AttendanceRecordsController < ApplicationController

	before_action :set_institute

	def set_institute
		@institute = Institute.find_by(id: params[:institute_id])
		head :ok and return if @institute.blank?
	end 

	def index
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

		if(current_user.role.include?("Institute Admin") or current_user.role.include?("Principal"))

			@all_section_member_models = @institute.institutes_sections_members_models
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
				@todays_attendance_record = @section_attendance_records.find_by(date: Date.today)
				
				@total_section_students = @section_students.count * @section_attendance_records.count
				@total_section_present_students = 0
				@section_attendance_records.each do |record|
					@total_section_present_students = @total_section_present_students + record.present_student_ids.split(", ").count
				end
				@total_section_absent_students = @total_section_students - @total_section_present_students

				
			end
			render "admin_attendance_page"
			return
		end

		if(current_user.role.include?("Teacher"))
			@assigned_classteacher_grades_sections_model = current_user.assigned_classteacher_grades_sections_models.first
			if(!@assigned_classteacher_grades_sections_model.blank?)
				@attendance_records = current_user.created_attendance_records.where("date >= ? AND date <= ?", params[:start_date], params[:end_date])
				if(@attendance_records.blank?)
					
					params[:start_date] = Date.yesterday
					
					@attendance_records = current_user.created_attendance_records.where("date >= ? AND date <= ?", params[:start_date], params[:end_date])
				end
				@institute = @assigned_classteacher_grades_sections_model.institute
				@grade = @assigned_classteacher_grades_sections_model.grade
				@section = @assigned_classteacher_grades_sections_model.section
				@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")

				@total_students = @class_students.count * @attendance_records.count
				@total_present_students = 0
				@attendance_records.each do |record|
					@total_present_students = @total_present_students + record.present_student_ids.split(", ").count
				end
				@total_absent_students = @total_students - @total_present_students

				
			end
			render "teacher_attendance_page"
		end

		if(current_user.role == "Student")
			@member_section_model = current_user.members_sections.first
			if(!@member_section_model.blank?)
				@attendance_records = @institute.attendance_records.where("date >= ? AND date <= ? AND grade_id = ? AND section_id = ?", params[:start_date], params[:end_date], @member_section_model.grade_id, @member_section_model.section_id)
				if(@attendance_records.blank?)
					
					params[:start_date] = Date.yesterday
					
					@attendance_records = @institute.attendance_records.where("date >= ? AND date <= ? AND grade_id = ? AND section_id = ?", params[:start_date], params[:end_date], @member_section_model.grade_id, @member_section_model.section_id)
				end
				@grade = @member_section_model.grade
				@section = @member_section_model.section
				@student =  current_user

				@total_days = @attendance_records.count
				@total_present_days = 0
				@attendance_records.each do |record|
					@total_present_days = @total_present_days + 1 if record.present_student_ids.split(", ").include?(@student.id.to_s)
				end
				@total_absent_days = @total_days - @total_present_days

				
			end
			render "student_attendance_page"
		end

		if(current_user.role == "Parent")
			if(!current_user.child_ids.blank?)
				child = current_user.children.first
				@member_section_model = child.members_sections.first
				if(!@member_section_model.blank?)
					@attendance_records = @institute.attendance_records.where("date >= ? AND date <= ? AND grade_id = ? AND section_id = ?", params[:start_date], params[:end_date], @member_section_model.grade_id, @member_section_model.section_id)
					if(@attendance_records.blank?)
						
						params[:start_date] = Date.yesterday
						
						@attendance_records = @institute.attendance_records.where("date >= ? AND date <= ?", params[:start_date], params[:end_date])
					end
					@grade = @member_section_model.grade
					@section = @member_section_model.section
					@student =  child

					@total_days = @attendance_records.count
					@total_present_days = 0
					@attendance_records.each do |record|
						@total_present_days = @total_present_days + 1 if record.present_student_ids.split(", ").include?(@student.id.to_s)
					end
					@total_absent_days = @total_days - @total_present_days

					
				end
				render "student_attendance_page"
			end
			
		end
	end

	def new

	end

	def create
		if(params[:present_student_ids].blank?)
			params[:present_student_ids] = [""]
		end

		@grade = Grade.find_by(id: params[:grade_id])
		@section = Section.find_by(id: params[:section_id])
		

		@todays_attendance_record = @institute.attendance_records.find_by(date: Date.today, grade_id: @grade.id, section_id: @section.id) 
		if(@todays_attendance_record.blank?)
			@todays_attendance_record = @institute.attendance_records.create(present_student_ids: params[:present_student_ids].join(", "), date: Date.today, grade_id: @grade.id, section_id: @section.id, creator_id: current_user.id)
		else
			@todays_attendance_record.update(present_student_ids: params[:present_student_ids].join(", "))
			
		end
		PublishAttendanceWorker.perform_async(@todays_attendance_record.id)
		@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
	end

	def show

	end

	def edit

	end

	def update

	end

	def destroy

	end

	def section_attendance_record_form
		if(!params[:grade_id].blank? and !params[:section_id].blank?)
			@grade = Grade.find_by(id: params[:grade_id])
			@section = Section.find_by(id: params[:section_id])
			@class_students =  @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, "Student")
			if(params[:date].blank?)
				@date = Date.today	
			else
				@date = Date.parse(params[:date]) 	
			end
			
			@attendance_record = @institute.attendance_records.find_by(date: @date, grade_id: @grade.id, section_id: @section.id) 
			render format: :js, layout: false if request.xhr?
		end
	end

end
