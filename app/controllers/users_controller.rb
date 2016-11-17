class UsersController < ApplicationController

  before_action :set_user, except: :index
  def set_user
    @user = User.find_by(id: params[:id])
  end

  def index
  
  end

  def show
  end

  def edit
  end

  def update
      @user.first_name = params[:first_name]
      @user.last_name = params[:last_name]
      @user.gender = params[:gender]
      @user.email = params[:email]
      @user.isd_code = params[:isd_code]
      @user.mobile_no = params[:mobile_no]
      @user.save
      if(!params[:profile_picture].blank?)
        @user.profile_picture.media = params[:profile_picture]
        @user.profile_picture.save 
      end
      redirect_to user_path(@user)
  end

  def destroy
  end

  def complete_registration
    if(request.get?)
      render 
    elsif(request.post?)
      if(!@user.blank?)
        if(params[:role] == "Institute Admin" or params[:role] == "Principal")
          @user.update(role: params[:role], is_registration_complete: true)
          if(!params[:profile_picture].blank?)
            @user.profile_picture.media = params[:profile_picture]
            @user.profile_picture.save 
          end

          if(!params[:institute_name].blank?)
            @institute = @user.created_institutes.create(institute_name: params[:institute_name])
            if(!params[:institute_latitude].blank? and !params[:institute_longitude].blank?)
              @institute.create_location(latitude: params[:institute_latitude], longitude: params[:institute_longitude])
            end
            @institute_conversation = @user.created_conversations.create(conversation_name: params[:institute_name].capitalize.truncate(50), institute_id: @institute.id, is_custom_group: false, message_categories: "Notice")
            
            if(!params[:grades].blank?)
              params[:grades].each do |grade_id, grade_extras|
                grade = Grade.find_by(id: grade_id)
                @institute.institutes_grades.create(grade_id: grade.id, creator_id: @user.id) if !grade.blank?
                
                grade_extras[:section_ids].each do |section_id|
                  section = Section.find_by(id: section_id)
                  @institute.institutes_grades_sections_models.create(grade_id: grade.id, section_id: section.id, creator_id: @user.id) if !grade.blank? and !section.blank?
                  
                  @section_conversation = @user.created_conversations.create(conversation_name: "Class #{grade.grade_name} #{section.section_name}, #{@institute.short_name}".truncate(20), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, message_categories: "HomeWork, Test", is_custom_group: false) if !grade.blank? and !section.blank?

                  grade_extras[:subject_ids].each do |subject_id|
                    subject = Subject.find_by(id: subject_id)
                    @institute.institutes_sections_subjects_models.create(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, creator_id: @user.id) if !grade.blank? and !section.blank? and !subject.blank?

                    @subject_conversation = @user.created_conversations.create(conversation_name: "#{subject.subject_name}, #{grade.grade_name} #{section.section_name}, #{@institute.short_name}".truncate(20), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, message_categories: "HomeWork, Test", is_custom_group: false) if !grade.blank? and !section.blank? and !subject.blank?
                  end
                  
                end
              end
            end
            redirect_to root_path
          end
        else
          @user.update(role: params[:role])
          if(!params[:institute_contact_info].blank?)
            if(is_valid_email(params[:institute_contact_info]))
              render partial: "institutes/institute_info_submission", locals: {institute_email: params[:institute_contact_info], institute_mobile: nil, institute_name: params[:institute_name]}
            else
              render partial: "institutes/institute_info_submission", locals: {institute_email: nil, institute_mobile: params[:institute_contact_info], institute_name: params[:institute_name]}
            end
            return
          end
          
        end
      end          
    end 
  end
end
