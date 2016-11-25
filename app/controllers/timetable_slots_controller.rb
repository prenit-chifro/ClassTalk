class TimetableSlotsController < ApplicationController
  
    before_action :set_grade_and_section, except: [:index]

    def set_grade_and_section
        @grade = Grade.find_by(id: params[:grade_id]) if !params[:grade_id].blank?
        @section = Section.find_by(id: params[:section_id]) if !params[:grade_id].blank?

        if(!params[:grade_section_id].blank?)
            @grade_section_model = GradeSection.find_by(id: params[:grade_section_id]) 
            @grade = @grade_section_model.grade if !@grade_section_model.blank?
            @section = @grade_section_model.section if !@grade_section_model.blank?
        end
        
    end

    before_action :set_timetable_slot, only: [:show, :edit, :update, :destroy]

    def set_timetable_slot
        @timetable_slot = TimetableSlot.find_by(id: params[:id])
        if(!params[:slot_for].blank? and params[:slot_for] == "Teacher")
            @grade_section_model = GradeSection.find_by(institute_id: @institute.id, grade_id: @timetable_slot.grade_id, section_id: @timetable_slot.section_id) if !@timetable_slot.blank?

            @grade_section_models = @institute.institutes_grades_sections_models
            @subjects = @institute.institutes_sections_subjects_models.map{|model| model.subject}.uniq
        else
            @grade = @timetable_slot.grade if !@timetable_slot.blank?
            @section = @timetable_slot.section if !@timetable_slot.blank?
            @teachers = @institute.get_members_with_given_roles(["Teacher"]) 
            @subjects = @section.subjects.uniq
        end
        @subject = @timetable_slot.subject if !@timetable_slot.blank?
        @teacher = @timetable_slot.teacher if !@timetable_slot.blank?
        
    end

    def index
        
        if(current_user.role == "Institute Admin")
            respond_to do |format|
                format.json do

                    if(!params[:teacher_id].blank?)
                        @teacher = User.find_by(id: params[:teacher_id])
                        @teacher_timetable_slots = @institute.timetable_slots.where(teacher_id: @teacher.id)
                    end
                    if(!params[:grade_id].blank? and !params[:section_id].blank?) 
                        @grade = Grade.find_by(id: params[:grade_id])
                        @section = Section.find_by(id: params[:section_id])
                        if(!@grade.blank? and !@section.blank?)
                            @class_timetable_slots = @section.timetable_slots.where(institute_id: @institute.id, grade_id: @grade.id)
                        end           
                        
                    end
 
                    render "index.json.jbuilder"
                end

                format.html do
                    @institutes_grade_section_models = @institute.institutes_grades_sections_models
                    @teachers = @institute.get_members_with_given_roles(["Teacher"]) 
                    render :admin_timetable   
                end
            end
            
        end

        if(current_user.role == "Teacher")
            respond_to do |format|
                format.json do
                    @teacher_timetable_slots = @institute.timetable_slots.where(teacher_id: current_user.id)
                    render "index.json.jbuilder"
                end

                format.html do
                    render :teacher_timetable   
                end
            end
        end

        if(current_user.role == "Student" or current_user.role == "Parent")
            respond_to do |format|
                format.json do
                    @grade = Grade.find_by(id: params[:grade_id])
                    @section = Section.find_by(id: params[:section_id])
                    if(!@grade.blank? and !@section.blank?)
                        @class_timetable_slots = @section.timetable_slots.where(institute_id: @institute.id, grade_id: @grade.id)
                    end
                    
                    render "index.json.jbuilder"
                end

                format.html do
                    @section_member_models = current_user.members_sections
                    render :student_timetable   
                end
            end
        end 
    end

    def new

        respond_to do |format|
          format.html do
            render
          end

          format.js do
            if(!params[:teacher_id].blank?)
                @teacher = User.find_by(id: params[:teacher_id])
                @grade_section_models = @institute.institutes_grades_sections_models
                @subjects = @institute.institutes_sections_subjects_models.map{|model| model.subject}.uniq
            else
                @teachers = @institute.get_members_with_given_roles(["Teacher"]) 
                @subjects = @section.subjects.uniq
            end
            
            render :new_slot_form
          end
        end
        
    end

    def create
        if(!params[:grade_section_id].blank? and !params[:teacher_id].blank?)
            @teacher = User.find_by(id: params[:teacher_id])
            if(@teacher.blank?)
                teacher_id = ""
            else
                teacher_id = @teacher.id
            end
            @grade_section_model = GradeSection.find_by(id: params[:grade_section_id])
            @subject = Subject.find_by(id: params[:subject_id])
            @timetable_slot = @section.timetable_slots.create(institute_id: @institute.id, grade_id: @grade_section_model.grade_id, section_id: @grade_section_model.section_id, subject_id: @subject.id, teacher_id: teacher_id, start_time: Time.parse(params[:start_time]), end_time: Time.parse(params[:end_time]))
        end

        if(!params[:subject_id].blank?)
            @subject = Subject.find_by(id: params[:subject_id])
            if(params[:teacher_id].blank?)
                @subject_teacher = @section.get_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, @subject)
            else
                @subject_teacher = User.find_by(id: params[:teacher_id])
            end
      
            if(@subject_teacher.blank?)
                teacher_id = ""
            else
                teacher_id = @subject_teacher.id
            end
            @timetable_slot = @section.timetable_slots.create(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: @subject.id, teacher_id: teacher_id, start_time: Time.parse(params[:start_time]), end_time: Time.parse(params[:end_time])) 
        end
    end

    def show
    
    end

    def edit
        respond_to do |format|
          format.html do
              render
          end

          format.js do
            render :edit_slot_form
          end
        end 
    end

    def update
        if(!params[:grade_section_id].blank? and !params[:teacher_id].blank?)
            @teacher = User.find_by(id: params[:teacher_id])
            if(@teacher.blank?)
                teacher_id = ""
            else
                teacher_id = @teacher.id
            end
            @grade_section_model = GradeSection.find_by(id: params[:grade_section_id])
            @subject = Subject.find_by(id: params[:subject_id])
            @timetable_slot.update(institute_id: @institute.id, grade_id: @grade_section_model.grade_id, section_id: @grade_section_model.section_id, subject_id: @subject.id, teacher_id: teacher_id, start_time: Time.parse(params[:start_time]), end_time: Time.parse(params[:end_time]))
            @updated = true
        end

        if(!params[:subject_id].blank? and !params[:teacher_id].blank?)
            @subject = Subject.find_by(id: params[:subject_id])
            if(params[:teacher_id].blank?)
                @subject_teacher = @section.get_subject_teacher_for_institute_and_grade_and_subject(@institute, @grade, @subject)
            else
                @subject_teacher = User.find_by(id: params[:teacher_id])
            end
      
            if(@subject_teacher.blank?)
                teacher_id = ""
            else
                teacher_id = @subject_teacher.id
            end
            @timetable_slot.update(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: @subject.id, teacher_id: teacher_id, start_time: Time.parse(params[:start_time]), end_time: Time.parse(params[:end_time])) 
            @updated = true
        end

        if(!@updated)
            @timetable_slot.update(start_time: Time.parse(params[:start_time]), end_time: Time.parse(params[:end_time])) 
        end

    end

    def destroy
        if(!@timetable_slot.blank?)
            @slot_id = @timetable_slot.id
            @grade_id = @timetable_slot.grade_id
            @section_id = @timetable_slot.section_id
            @teacher_id = @timetable_slot.teacher_id
            @timetable_slot.destroy    
        end
    end

end
