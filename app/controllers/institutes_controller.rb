class InstitutesController < ApplicationController
  
  before_action :set_institute, except: [:index, :new, :create]
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
      if(!@institute.blank?)
          @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
          @principals = @institute.get_members_with_given_roles(["Principal"])
          @admins = @institute.get_members_with_given_roles(["Institute Admin"])
          @teachers = @institute.get_members_with_given_roles(["Teacher"])
          @students = @institute.get_members_with_given_roles(["Student"])
          @parents = @institute.get_members_with_given_roles(["Parent"])
          if(current_user.role.include?("Institute Admin"))
              @grades = @institute.grades
          else
              @section_member_models = current_user.members_sections
              @grades = @section_member_models.map(&:grade).uniq 
          end
      end
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
          
          send_user_account_password_through_email(@new_member, password) if !@new_member.email.blank?
          send_user_account_password_through_sms(@new_member, password) if !@new_member.mobile_no.blank?
          
        end
        
        @institute.add_member(@new_member.id, current_user.id, role) 
        @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
        @institute_conversation.add_participant(@new_member.id, current_user.id) if !@institute_conversation.blank?  

        if(role == "Principal" or role == "Institute Admin")
            grades = @institute.grades
            grades.each do |grade|
               sections = grade.sections
               sections.each do |section|
                  section.add_member_for_institute_and_grade(@institute, grade, current_user, @new_member, role)
                  section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) 
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
          
          section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false)
          
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
          section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) if !section.blank?
          
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
              
              section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil) if !section.blank?
              section_conversation.add_participant(@new_member.id, current_user.id) if !section_conversation.blank?
              
            end
          end
        end
        flash[:notice] = "Successfully added #{@new_member.first_name} to #{@institute.institute_name} as #{role}."     
        redirect_to root_path
        
      end
    end    
  end

  def add_new_student
    if(request.get?)
        @institutes_grades_sections_models = @institute.institutes_grades_sections_models
        @grades = @institutes_grades_sections_models.map(&:grade).uniq
        @sections = @institutes_grades_sections_models.map(&:section).uniq

        render "add_new_student_step_1"
    end

    if(request.post?)
        if(!params[:step].blank? and params[:step].to_i == 1)
            @student = nil
            if(!params[:email].blank?)
                @student = User.find_by(email: params[:email])
            end
            if(@student.blank? and !params[:mobile_no].blank?)
                @student = User.find_by(mobile_no: params[:mobile_no])
            end
            if(@student.blank?)
                password = Random.new.rand(1000..9999).to_s
                @student = User.new(role: "Student")
                @student.password = password
                @student.first_name = params[:first_name] if !params[:first_name].blank?
                @student.last_name = params[:last_name] if !params[:last_name].blank?
                @student.isd_code = params[:isd_code] if !params[:isd_code].blank?
                @student.mobile_no = params[:mobile_no] if !params[:mobile_no].blank?
                @student.email = params[:email] if !params[:email].blank?
                @student.gender = params[:gender] if !params[:gender].blank?
                @student.date_of_birth = params[:date_of_birth] if !params[:date_of_birth].blank?
                @student.address = params[:address] if !params[:address].blank?
                @student.pincode = params[:pincode] if !params[:pincode].blank?
                @student.role_no = params[:role_no] if !params[:role_no].blank?
                @student.is_registration_complete = true
                @student.is_using_transport = params[:is_using_transport] if !params[:is_using_transport].blank?
                @student.save
                save_user_password_with_system_encryption_key(@student, password)
                send_user_account_password_through_email(@student, password) if !params[:email].blank?
                send_user_account_password_through_sms(@student, password) if !@student.mobile_no.blank?
          
            end
            @institute.add_member(@student.id, current_user.id, "Student") 
            @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
            @institute_conversation.add_participant(@student.id, current_user.id) if !@institute_conversation.blank?  

            if(!params[:grade_id].blank? and !params[:section_id].blank?)
                @grade = Grade.find_by(id: params[:grade_id])
                @section = Section.find_by(id: params[:section_id])

                @section.add_member_for_institute_and_grade(@institute, @grade, current_user, @student, "Student") if !@section.blank?
                
                section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: nil, is_custom_group: false)
                
                section_conversation.add_participant(@student.id, current_user.id) if !section_conversation.blank?

                sections_subjects = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
                sections_subjects.each do |section_subject|
                    subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: section_subject.subject_id, is_custom_group: false)
                    subject_conversation.add_participant(@student.id, current_user.id) if !subject_conversation.blank?
                end
                parents = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Parent"]) 
                @male_parents = parents.map{|parent| parent if parent.gender == "male"}.compact.uniq
                @female_parents = parents.map{|parent| parent if parent.gender == "female"}.compact.uniq
                
            end

            render "add_new_student_step_1.js"
        end
        if(!params[:step].blank? and params[:step].to_i == 2)
            if(!params[:student_id].blank?)
                @student = User.find_by(id: params[:student_id])
            end
            if(!params[:father_id].blank?)
                @father = User.find_by(id: params[:father_id])
            else 
                if(!params[:father_mobile_no].blank? or !params[:father_email].blank?)
                
                    @father = nil
                    if(!params[:father_mobile_no].blank?)
                        @father = User.find_by(mobile_no: params[:father_mobile_no])
                    end
                    if(@father.blank? and !params[:father_email].blank?)
                        @father = User.find_by(email: params[:father_email])
                    end
                    if(@father.blank?)
                        password = Random.new.rand(1000..9999).to_s
                        @father = User.new(role: "Parent")
                        @father.password = password
                        @father.first_name = params[:father_first_name] if !params[:father_first_name].blank?
                        @father.last_name = params[:father_last_name] if !params[:father_last_name].blank?
                        @father.mobile_no = params[:father_mobile_no] if !params[:father_mobile_no].blank?
                        @father.email = params[:father_email] if !params[:father_email].blank?
                        @father.gender = "male"
                        
                        @father.address = @student.address if !@student.blank?
                        @father.pincode = @student.pincode if !@student.blank?
                        @father.is_using_transport = @student.is_using_transport if !@student.blank?
                        @father.is_registration_complete = true
                        
                        @father.save
                        save_user_password_with_system_encryption_key(@father, password)
                        send_user_account_password_through_email(@father, password) if !params[:father_email].blank?
                        send_user_account_password_through_sms(@father, password) if !@father.mobile_no.blank?
                  
                    end
                    
                end
            end

            if(!params[:mother_id].blank?)
                @mother = User.find_by(id: params[:mother_id])
            else
                if(!params[:mother_mobile_no].blank? or !params[:mother_email].blank?)
                
                    @mother = nil
                    if(!params[:mother_mobile_no].blank?)
                        @mother = User.find_by(mobile_no: params[:mother_mobile_no])
                    end
                    if(@mother.blank? and !params[:mother_email].blank?)
                        @mother = User.find_by(email: params[:mother_email])
                    end
                    if(@mother.blank?)
                        password = Random.new.rand(1000..9999).to_s
                        @mother = User.new(role: "Parent")
                        @mother.password = password
                        @mother.first_name = params[:mother_first_name] if !params[:mother_first_name].blank?
                        @mother.last_name = params[:mother_last_name] if !params[:mother_last_name].blank?
                        @mother.mobile_no = params[:mother_mobile_no] if !params[:mother_mobile_no].blank?
                        @mother.email = params[:mother_email] if !params[:mother_email].blank?
                        @mother.gender = "female"
                        
                        @mother.address = @student.address if !@student.blank?
                        @mother.pincode = @student.pincode if !@student.blank?
                        @mother.is_using_transport = @student.is_using_transport if !@student.blank?
                        @mother.is_registration_complete = true
                        
                        @mother.save
                        save_user_password_with_system_encryption_key(@mother, password)
                        send_user_account_password_through_email(@mother, password) if !params[:father_email].blank?
                        send_user_account_password_through_sms(@mother, password) if !@mother.mobile_no.blank?
                  
                    end
                    
                end
            end

            if(!@student.blank? and !@father.blank?)
                 @student.father_id = @father.id
                if(@father.child_ids.blank?)
                    @father.update(child_ids: @student.id.to_s)
                else
                    @father.update(child_ids: @father.child_ids + ", " +@student.id.to_s)
                end
            end

            if(!@student.blank? and !@mother.blank?)
                @student.mother_id = @mother.id if !@mother.blank?
                if(@mother.child_ids.blank?)
                    @mother.update(child_ids: @student.id.to_s)
                else
                    @mother.update(child_ids: @mother.child_ids + ", " +@student.id.to_s)
                end
            end
            @student.save if !@student.blank?

            @institute.add_member(@father.id, current_user.id, "Parent") if !@father.blank? 
            @institute.add_member(@mother.id, current_user.id, "Parent") if !@mother.blank? 

            @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
            @institute_conversation.add_participant(@father.id, current_user.id) if !@institute_conversation.blank? and !@father.blank?
            @institute_conversation.add_participant(@mother.id, current_user.id) if !@institute_conversation.blank? and !@mother.blank?  

            if(!params[:grade_id].blank? and !params[:section_id].blank?)
                @grade = Grade.find_by(id: params[:grade_id])
                @section = Section.find_by(id: params[:section_id])

                @section.add_member_for_institute_and_grade(@institute, @grade, current_user, @father, "Parent") if !@section.blank? and !@father.blank?
                @section.add_member_for_institute_and_grade(@institute, @grade, current_user, @mother, "Parent") if !@section.blank? and !@mother.blank?
                
                section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: nil, is_custom_group: false)
                
                section_conversation.add_participant(@father.id, current_user.id) if !section_conversation.blank? and !@father.blank?
                section_conversation.add_participant(@mother.id, current_user.id) if !section_conversation.blank? and !@mother.blank?

                sections_subjects = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
                sections_subjects.each do |section_subject|
                    subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: section_subject.subject_id, is_custom_group: false)
                    subject_conversation.add_participant(@father.id, current_user.id) if !subject_conversation.blank? and !@father.blank?
                    subject_conversation.add_participant(@mother.id, current_user.id) if !subject_conversation.blank? and !@mother.blank?
                end
                
            end
            
            render "add_new_student.js"
        end        
    end
  end

  def add_new_parent
    if(request.get?)
        @institutes_grades_sections_models = @institute.institutes_grades_sections_models
        @grades = @institutes_grades_sections_models.map(&:grade).uniq
        @sections = @institutes_grades_sections_models.map(&:section).uniq
        render "add_new_parent_step_1"
    end

    if(request.post?)
        if(!params[:step].blank? and params[:step].to_i == 1)
            @parent = nil
            if(!params[:email].blank?)
                @parent = User.find_by(email: params[:email])
            end
            if(@parent.blank? and !params[:mobile_no].blank?)
                @parent = User.find_by(mobile_no: params[:mobile_no])
            end
            if(@parent.blank?)
                password = Random.new.rand(1000..9999).to_s
                @parent = User.new(role: "Student")
                @parent.password = password
                @parent.first_name = params[:first_name] if !params[:first_name].blank?
                @parent.last_name = params[:last_name] if !params[:last_name].blank?
                @parent.mobile_no = params[:mobile_no] if !params[:mobile_no].blank?
                @parent.email = params[:email] if !params[:email].blank?
                @parent.gender = params[:gender] if !params[:gender].blank?
                
                @parent.address = params[:address] if !params[:address].blank?
                @parent.pincode = params[:pincode] if !params[:pincode].blank?
                @parent.is_using_transport = params[:is_using_transport] if !params[:is_using_transport].blank?
                @parent.is_registration_complete = true
                
                @parent.save
                save_user_password_with_system_encryption_key(@parent, password)
                send_user_account_password_through_email(@parent, password) if !params[:email].blank?
                send_user_account_password_through_sms(@parent, password) if !@parent.mobile_no.blank?
          
            end
            @institute.add_member(@parent.id, current_user.id, "Student") 
            @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
            @institute_conversation.add_participant(@parent.id, current_user.id) if !@institute_conversation.blank?  

            if(!params[:grade_id].blank? and !params[:section_id].blank?)
                @grade = Grade.find_by(id: params[:grade_id])
                @section = Section.find_by(id: params[:section_id])

                @section.add_member_for_institute_and_grade(@institute, @grade, current_user, @parent, "Student") if !@section.blank?
                
                section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: nil, is_custom_group: false)
                
                section_conversation.add_participant(@parent.id, current_user.id) if !section_conversation.blank?

                sections_subjects = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
                sections_subjects.each do |section_subject|
                    subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: section_subject.subject_id, is_custom_group: false)
                    subject_conversation.add_participant(@parent.id, current_user.id) if !subject_conversation.blank?
                end
                @students = @section.get_members_with_given_roles_for_institute_and_grade_with_role(@institute, @grade, ["Student"]) 
                
            end

            render "add_new_parent_step_1.js"
        end
        if(!params[:step].blank? and params[:step].to_i == 2)
            if(!params[:parent_id].blank?)
                @parent = User.find_by(id: params[:parent_id])
            end
            if(!params[:child_id].blank?)
                @child = User.find_by(id: params[:child_id])
            else 
                
                
                    @child = nil
                    if(!params[:child_mobile_no].blank?)
                        @child = User.find_by(mobile_no: params[:child_mobile_no])
                    end
                    if(@child.blank? and !params[:child_email].blank?)
                        @child = User.find_by(email: params[:child_email])
                    end
                    if(@child.blank?)
                        password = Random.new.rand(1000..9999).to_s
                        @child = User.new(role: "Parent")
                        @child.password = password
                        @child.first_name = params[:child_first_name] if !params[:child_first_name].blank?
                        @child.last_name = params[:child_last_name] if !params[:child_last_name].blank?
                        @child.mobile_no = params[:child_mobile_no] if !params[:child_mobile_no].blank?
                        @child.email = params[:child_email] if !params[:child_email].blank?
                        @child.gender = params[:child_gender] if !params[:child_gender].blank?
                        @child.roll_no = params[:child_roll_no] if !params[:child_roll_no].blank?
                        @child.date_of_birth = params[:child_date_of_birth] if !params[:child_date_of_birth].blank?
                        @child.is_using_transport = @parent.is_using_transport if !@parent.blank?
                        @child.address = @parent.address if !@parent.blank?
                        @child.pincode = @parent.pincode if !@parent.blank?
                        
                        @child.is_registration_complete = true
                        
                        @child.save
                        save_user_password_with_system_encryption_key(@child, password)
                        send_user_account_password_through_email(@child, password) if !params[:child_email].blank?
                        send_user_account_password_through_sms(@child, password) if !@child.mobile_no.blank?
                  
                    end
                    
                
            end

            
            if(!@child.blank? and !@parent.blank?)
                @child.father_id = @parent.id if @parent.gender == "male"
                @child.mother_id = @parent.id if @parent.gender == "female"
                @child.save 

                if(@parent.child_ids.blank?)
                    @parent.update(child_ids: @child.id.to_s)
                else
                    @parent.update(child_ids: @parent.child_ids + ", " +@child.id.to_s)
                end
            end

            @institute.add_member(@child.id, current_user.id, "Parent") if !@child.blank? 

            @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
            @institute_conversation.add_participant(@child.id, current_user.id) if !@institute_conversation.blank? and !@child.blank?
            
            if(!params[:grade_id].blank? and !params[:section_id].blank?)
                @grade = Grade.find_by(id: params[:grade_id])
                @section = Section.find_by(id: params[:section_id])

                @section.add_member_for_institute_and_grade(@institute, @grade, current_user, @child, "Parent") if !@section.blank? and !@child.blank?
                                
                section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: nil, is_custom_group: false)
                
                section_conversation.add_participant(@child.id, current_user.id) if !section_conversation.blank? and !@child.blank?
                
                sections_subjects = @section.sections_subjects.where(institute_id: @institute.id, grade_id: @grade.id)
                sections_subjects.each do |section_subject|
                    subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: @grade.id, section_id: @section.id, subject_id: section_subject.subject_id, is_custom_group: false)
                    subject_conversation.add_participant(@child.id, current_user.id) if !subject_conversation.blank? and !@child.blank?
                end
                
            end
            
            render "add_new_parent.js"
        end        
    end
  end

  def add_new_staff
    if(request.get?)
        render "add_new_staff.html"
    end

    if(request.post?)
        if(!params[:step].blank? and params[:step].to_i == 1)
            @staff = nil
            if(!params[:email].blank?)
                @staff = User.find_by(email: params[:email])
            end
            if(@staff.blank? and !params[:mobile_no].blank?)
                @staff = User.find_by(mobile_no: params[:mobile_no])
            end
            if(@staff.blank?)
                password = Random.new.rand(1000..9999).to_s
                @staff = User.new(role: "Student")
                @staff.password = password
                @staff.first_name = params[:first_name] if !params[:first_name].blank?
                @staff.last_name = params[:last_name] if !params[:last_name].blank?
                @staff.mobile_no = params[:mobile_no] if !params[:mobile_no].blank?
                @staff.email = params[:email] if !params[:email].blank?
                @staff.gender = params[:gender] if !params[:gender].blank?
                
                @staff.address = params[:address] if !params[:address].blank?
                @staff.pincode = params[:pincode] if !params[:pincode].blank?
                @staff.role = params[:role] if !params[:role].blank?
                @staff.staff_id = params[:staff_id] if !params[:staff_id].blank?
                @staff.is_using_transport = params[:is_using_transport] if !params[:is_using_transport].blank?
                @staff.is_registration_complete = true
                
                @staff.save
                save_user_password_with_system_encryption_key(@staff, password)
                send_user_account_password_through_email(@staff, password) if !params[:email].blank?
                send_user_account_password_through_sms(@staff, password) if !@staff.mobile_no.blank?
          
            end
            @institute.add_member(@staff.id, current_user.id, params[:role]) if !params[:role].blank?
            @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
            @institute_conversation.add_participant(@staff.id, current_user.id) if !@institute_conversation.blank? and !@staff.blank? 

            @institutes_grades_sections_models = @institute.institutes_grades_sections_models
            @grades = @institutes_grades_sections_models.map(&:grade).uniq
            @sections = @institutes_grades_sections_models.map(&:section).uniq
            
            render "add_new_staff_step_1.js"
        end
        if(!params[:step].blank? and params[:step].to_i == 2)
            if(!params[:staff_id].blank?)
                @staff = User.find_by(id: params[:staff_id])
            end
            
            if(@staff.role == "Teacher" and !params[:classteacher_grade_id].blank? and !params[:classteacher_section_id].blank?)
              grade = @institute.grades.find_by(id: params[:classteacher_grade_id])
              section = grade.get_sections_for_institute(@institute).find_by(id: params[:classteacher_section_id])
                
              section.add_member_for_institute_and_grade(@institute, grade, current_user, @staff, "Teacher") if !section.blank?
              section.set_classteacher_for_institute_and_grade(@institute, grade, @staff) if !section.blank?
              section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) if !section.blank?
              
              section_conversation.add_participant(@staff.id, current_user.id) if !section_conversation.blank? if !section.blank?
                
              
            end
            
            if(@staff.role == "Teacher" and !params[:grades].blank?)
              params[:grades].each do |grade_name, grade_extras|
                grade = @institute.grades.find_by(grade_name: grade_name)
                grade_extras[:section_names].each do |section_name|
                  section = grade.get_sections_for_institute(@institute).find_by(section_name: section_name) if !grade.blank?
                  
                  grade_extras[:subject_names].each do |subject_name|
                    subject = section.get_subjects_for_institute_and_grade(@institute, grade).find_by(subject_name: subject_name) if !section.blank?
                    section.set_subject_teacher_for_institute_and_grade_and_subject(@institute, grade, subject, @staff) if !section.blank?

                    subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, is_custom_group: false) if !section.blank? and !subject.blank?
                    subject_conversation.add_participant(@staff.id, current_user.id) if !subject_conversation.blank? and !section.blank?
                  end
                  
                  section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil) if !section.blank?
                  section_conversation.add_participant(@staff.id, current_user.id) if !section_conversation.blank?
                  
                end
              end
            end
            
            render "add_new_staff.js"
        end
    end
  end

  def give_admin_right
    if(request.get?)

        @current_admins = @institute.get_members_with_given_roles(["Institute Admin"])
        @teachers = @institute.get_members_with_given_roles(["Teacher"])
        render 
    elsif(request.post?)
        if(!params[:staff_id].blank?)
            @staff = User.find_by(id: params[:staff_id])
            if(!@staff.blank?)
                if(params[:start_time] <= Time.now)
                    AdminRightWorker.perform(@staff.id, "Add")
                else
                    AdminRightWorker.perform_at(params[:start_time], @staff.id, "Add")  
                end

                if(params[:end_time] <= Time.now)
                    AdminRightWorker.perform(@staff.id, "Remove")
                else
                    AdminRightWorker.perform_at(params[:end_time], @staff.id, "Remove")  
                end

            end
        end
    end


  end  
end
