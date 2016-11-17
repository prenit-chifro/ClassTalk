class InstitutesController < ApplicationController
  
  before_action :set_institute
  def set_institute
    @institute = Institute.find_by(id: params[:id])
  end 

  def index
  end

  def new
  end

  def create
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def add_new_member
    if(request.get?)
      if(request.xhr?)
        render layout: false
      end
    elsif(request.post?)
      profile_picture = params[:profile_picture]
      first_name = params[:first_name]
      last_name = params[:last_name]
      isd_code = params[:isd_code]
      mobile_no = params[:mobile_no]
      email = params[:email]
      gender = params[:gender]
      role = params[:role]

      if(!@institute.blank?)
        @new_member = nil
        @new_member = User.where(email: email).first if !email.blank?
        if(@new_member.blank?)
          @new_member = User.where(isd_code: isd_code, mobile_no: mobile_no).first if !mobile_no.blank?
        end
      
        if(!@new_member.blank?)
          if(@institute.chech_if_member(@new_member))
            flash[:notice] = "#{@new_member.first_name.capitalize} is already a member of #{@institute.institute_name}."     
            redirect_to root_path
          end
          @new_member.update(role: role) if @new_member.role .blank?
        else
          password = Random.new.rand(1000..9999).to_s
          @new_member = User.new
          @new_member.password = password
          @new_member.first_name = first_name if !first_name.blank?
          @new_member.last_name = last_name if !last_name.blank?
          @new_member.isd_code = isd_code if !isd_code.blank?
          @new_member.mobile_no = mobile_no if !mobile_no.blank?
          @new_member.email = email if !email.blank?
          @new_member.gender = gender if !gender.blank?
          @new_member.role = role if !role .blank?
          @new_member.is_registration_complete = true
          @new_member.save
          save_user_password_with_system_encryption_key(@new_member, password)
          if !profile_picture.blank?
            @new_member.profile_picture.media = profile_picture 
            @new_member.save
          end  
          
          #send_user_account_password_through_email(@new_member, password) if !@new_member.email.blank?
          #send_user_account_password_through_sms(@new_member, password) if !@new_member.contact_no.blank?
          
        end
        
        @institute.add_member(@new_member.id, current_user.id, role) 
        @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, is_custom_group: false)
        @institute_conversation.add_participant(@new_member.id, current_user.id) if !@institute_conversation.blank?  

        if(role == "Principal" or role == "Institute Admin")
            grades = @institute.grades
            grades.each do |grade|
               sections = grade.sections
               sections.each do |section|
                  section.add_member_for_institute_and_grade(@institute, grade, current_user, @new_member, role)
                  section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, is_custom_group: false) 
                  section_conversation.add_participant(@new_member.id, current_user.id) if !section_conversation.blank?

                  sections_subjects = section.sections_subjects.where(institute_id: @institute.id, grade_id: grade.id)
                  sections_subjects.each do |section_subject|
                      subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: section_subject.subject_id, is_custom_group: false)
                      subject_conversation.add_participant(@new_member.id, current_user.id) if !subject_conversation.blank?
                  end
                end


            end
            
        end

        if((role == "Parent" or role == "Student") and !params[:student_parent_grade_name].blank? and !params[:student_parent_section_name].blank?)
          grade = @institute.grades.find_by(grade_name: params[:student_parent_grade_name])
          section = grade.get_sections_for_institute(@institute).find_by(section_name: params[:student_parent_section_name])
          section.add_member_for_institute_and_grade(@institute, grade, current_user, @new_member, role) if !section.blank?
          
          section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, is_custom_group: false)
          
          section_conversation.add_participant(@new_member.id, current_user.id) if !section_conversation.blank?

          sections_subjects = section.sections_subjects.where(institute_id: @institute.id, grade_id: grade.id)
          sections_subjects.each do |section_subject|
              subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: section_subject.subject_id, is_custom_group: false)
              subject_conversation.add_participant(@new_member.id, current_user.id) if !subject_conversation.blank?
          end
        end
        
        if(role == "Teacher" and !params[:classteacher_grade_name].blank? and !params[:classteacher_section_name].blank?)
          grade = @institute.grades.find_by(grade_name: params[:classteacher_grade_name])
          section = grade.get_sections_for_institute(@institute).find_by(section_name: params[:classteacher_section_name])
            
          section.add_member_for_institute_and_grade(@institute, grade, current_user, @new_member, role) if !section.blank?
          section.set_classteacher_for_institute_and_grade(@institute, grade, @new_member) if !section.blank?
          section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, is_custom_group: false) if !section.blank?
          
          section_conversation.add_participant(@new_member.id, current_user.id) if !section_conversation.blank? if !section.blank?
            
          
        end
        
        if(role == "Teacher" and !params[:grades].blank?)
          params[:grades].each do |grade_name, grade_extras|
            grade = @institute.grades.find_by(grade_name: grade_name)
            grade_extras[:section_names].each do |section_name|
              section = grade.get_sections_for_institute(@institute).find_by(section_name: section_name) if !grade.blank?
              
              grade_extras[:subject_names].each do |subject_name|
                subject = section.get_subjects_for_institute_and_grade(@institute, grade).find_by(subject_name: subject_name) if !section.blank?
                section.set_subject_teacher_for_institute_and_grade_and_subject(@institute, grade, subject, @new_member) if !section.blank?

                subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, is_custom_group: false)
                subject_conversation.add_participant(@new_member.id, current_user.id) if !subject_conversation.blank?
              end
              
              section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id) if !section.blank?
              section_conversation.add_participant(@new_member.id, current_user.id) if !section_conversation.blank?
              
            end
          end
        end
        flash[:notice] = "Successfully added #{@new_member.first_name} to #{@institute.institute_name} as #{role}."     
        redirect_to root_path
        
      end
    end    
  end
end
