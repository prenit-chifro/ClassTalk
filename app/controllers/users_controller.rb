class UsersController < ApplicationController

  before_action :set_user, except: :index
  def set_user
    @user = User.find_by(id: params[:id])
  end

  def index
  
  end

  def show
    if(@user.role == "Teacher")
      @assigned_classteacher_grades_sections_model = @user.assigned_classteacher_grades_sections_models.first
      @teaching_sections_subjects_models = @user.teaching_sections_subjects_models
    end

    if(current_user.role == "Parent")
        @children = current_user.children
    end

    if(current_user.role == "Student")
        @father = current_user.father
        @mother = current_user.mother
    end    
  end

  def edit
      if(current_user.role == "Parent")
        @section_member_models = current_user.members_sections
        
        @children = current_user.children
        
      end

      if(current_user.role == "Student")
        section_member_model = current_user.members_sections.first
        grade = section_member_model.grade
        section = section_member_model.section
        parents = section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, grade, ["Parent"]) 
        @male_parents = parents.map{|parent| parent if parent.gender == "male"}.compact.uniq
        @female_parents = parents.map{|parent| parent if parent.gender == "female"}.compact.uniq
        
        @father = current_user.father
        @mother = current_user.mother
        
      end
  end

  def update
      @user.first_name = params[:first_name] if !params[:first_name].blank?
      @user.last_name = params[:last_name] if !params[:last_name].blank?
      @user.gender = params[:gender] if !params[:gender].blank?
      @user.email = params[:email] if !params[:email].blank?
      @user.isd_code = params[:isd_code] if !params[:isd_code].blank?
      @user.mobile_no = params[:mobile_no] if !params[:mobile_no].blank?
      
      if(!params[:father_id].blank?)

          @father = User.find_by(id: params[:father_id])
          if(!@father.blank?)
              @user.father_id = @father.id
              if(@father.child_ids.blank?)
                  @father.child_ids = @user.id.to_s
              else
                  @father.child_ids = @father.child_ids + ", #{@user.id}"
              end
              @father.save
          end
      end
      
      if(!params[:mother_id].blank?)

          @mother = User.find_by(id: params[:mother_id])
          if(!@mother.blank?)
              @user.mother_id = @mother.id
              if(@mother.child_ids.blank?)
                  @mother.child_ids = @user.id.to_s
              else
                  @mother.child_ids = @mother.child_ids + ", #{@user.id}"
              end
              @mother.save
          end
      end
      
      if(!params[:child_ids].blank?)
          @children = User.where(id: params[:child_ids])
          if(!@children.blank?)
              if(@user.child_ids.blank)
                  @user.child_ids = @children.map(&:id).join(", ")
              else
                  @user.child_ids = @user.child_ids + ", " + @children.map(&:id).join(", ")
              end

              if(@user.gender == "male")
                  @children.each do |child|
                      child.update(father_id: @user.id)
                  end
              end
              if(@user.gender == "female")
                  @children.each do |child|
                      child.update(mother_id: @user.id)
                  end
              end
          end
         
      end
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
      render layout: "devise"
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
            @institute_conversation = @user.created_conversations.create(conversation_name: params[:institute_name].capitalize.truncate(50), institute_id: @institute.id, is_custom_group: false, message_categories: "")
            
            if(!params[:grades].blank?)
              params[:grades].each do |grade_id, grade_extras|
                grade = Grade.find_by(id: grade_id)
                @institute.institutes_grades.create(grade_id: grade.id, creator_id: @user.id) if !grade.blank?
                
                grade_extras[:section_ids].each do |section_id|
                  section = Section.find_by(id: section_id)
                  @institute.institutes_grades_sections_models.create(grade_id: grade.id, section_id: section.id, creator_id: @user.id) if !grade.blank? and !section.blank?
                  
                  @section_conversation = @user.created_conversations.create(conversation_name: "Class #{grade.grade_name} #{section.section_name}, #{@institute.short_name}".truncate(20), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, message_categories: "HomeWork", is_custom_group: false) if !grade.blank? and !section.blank?

                  grade_extras[:subject_ids].each do |subject_id|
                    subject = Subject.find_by(id: subject_id)
                    @institute.institutes_sections_subjects_models.create(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, creator_id: @user.id) if !grade.blank? and !section.blank? and !subject.blank?

                    @subject_conversation = @user.created_conversations.create(conversation_name: "#{subject.subject_name}, #{grade.grade_name} #{section.section_name}, #{@institute.short_name}".truncate(20), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, message_categories: "HomeWork", is_custom_group: false) if !grade.blank? and !section.blank? and !subject.blank?
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
