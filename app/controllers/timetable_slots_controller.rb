class TimetableSlotsController < ApplicationController
  
    before_action :set_grade_and_section, except: [:index]

    def set_grade_and_section
        @grade = Grade.find_by(id: params[:grade_id]) 
        @section = Section.find_by(id: params[:section_id])
    end

    def index
        
        if(current_user.role == "Institute Admin")
            if(params[:grade_id].blank?)
                @institute_grade_models = @institute.institutes_grades 
                if(!@institute_grade_models.blank?)
                    @grade = @institute_grade_models.first.grade
                end   
            else
                @grade = Grade.find_by(id: params[:grade_id])
            end

            if(params[:section_id].blank?)
                @institutes_grade_section_models = @institute.institutes_grades_sections_models 
                if(!@institutes_grade_section_models.blank?)
                    @section = @institutes_grade_section_models.first.section
                end   
            else
                @section = Section.find_by(id: params[:section_id])
            end

            if(!@grade.blank? and !@section.blank?)
                @class_timetable_slots = @section.timetable_slots.where(institute_id: @institute.id, grade_id: @grade.id)
            end           
           
            if(!params[:teacher_id].blank?)
                @teacher = User.find_by(id: params[:teacher_id])
                @teachers_section_subject_models = @teacher.teaching_sections_subjects_models 
                if(!@teachers_section_subject_models.blank?)
                   
                end   
            end           
           

            respond_to do |format|
                format.js do 
                    render "index.json.jbuilder"
                end

                format.html do
                    render :admin_timetable   
                end
            end
            
        end

        if(current_user.role == "Teacher")
            render "teacher_timetable"
        end

        if(current_user.role == "Student")
            render "student_timetable"
        end 

        if(current_user.role == "Parent")
            render "student_timetable"
        end

    end

    def new

        respond_to do |format|
          format.html do
            render
          end

          format.js do
            @subjects = @section.subjects
            render :new_slot_form
          end
        end
        
    end

    def create
        @subject = Subject.find_by(id: params[:subject_id])
        @subject_teacher = @section.get_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, @subject)
        if(@subject_teacher.blank?)
            teacher_id = ""
        else
            teacher_id = @subject_teacher.id
        end
        @section.timetable_slots.create(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: @subject.id, teacher_id: teacher_id, start_time: DateTime.parse(params[:start_time]), end_time: DateTime.parse(params[:end_time]))
        render plain: params.inspect
    end

    def show
    
    end

    def edit
    
    end

    def update
    
    end

    def destroy
    
    end

end
