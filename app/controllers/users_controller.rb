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
      @user.staff_id = params[:staff_id] if !params[:staff_id].blank?
      @user.roll_no = params[:roll_no] if !params[:roll_no].blank?
      @user.address = params[:address] if !params[:address].blank?
      @user.pincode = params[:pincode] if !params[:pincode].blank?
      @user.date_of_birth = Date.parse(params[:date_of_birth]) if !params[:date_of_birth].blank?
      @user.is_using_transport = params[:is_using_transport]
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
    if(!@user.blank?)
        @user.destroy
        hash_url = ""
        if(@user.role.include?("Institute Admin") or @user.role.include?("Principal"))
          hash_url = "#all-admins"
        elsif(@user.role.include?("Teacher"))
          hash_url = "#all-teachers"
        else
          hash_url = "#all-students"
        end
        redirect_to institute_path(@institute) + hash_url
    else

    end
        
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
            
            if(!params[:institute_data_file].blank?)

              @institute_data_file = @institute.create_institute_data_file(media: params[:institute_data_file])
              
              require "spreadsheet"

              data_file = Spreadsheet.open(@institute_data_file.media.path)
              
              class_sheet = data_file.worksheet("Classes")
              if(!class_sheet.blank?)
                class_sheet_fields = class_sheet.row(0)
                section_names = class_sheet_fields[3..(class_sheet.rows.length - 1)]
                class_sheet.rows[1..(class_sheet.rows.length - 1)].each do |class_row|
                  
                  class_name = class_row[0]
                  grade = Grade.find_by(grade_name: class_name)
                  if(grade.blank?)
                    grade = Grade.create(grade_name: class_name)
                  end
                  
                  class_offered = class_row[1]

                  if(!class_offered.blank?)
                    class_custom_name = class_row[2]
                    
                    @institute.institutes_grades.create(custom_grade_name: class_custom_name, grade_id: grade.id, creator_id: current_user.id)
                    section_names.each do |section_name|
                      if(!section_name.blank?)
                        section = Section.find_by(section_name: section_name.split(" ").last)
                        if(section.blank?)
                          section = Section.create(section_name: section_name.split(" ").last)
                        end
                        if(!class_row[class_sheet_fields.index(section_name)].blank?)
                          
                          grade_section_model = @institute.institutes_grades_sections_models.create(grade_id: grade.id, section_id: section.id, creator_id: current_user.id) if !grade.blank? and !section.blank?
                          section_conversation = current_user.created_conversations.create(conversation_name: "#{grade.custom_name_for_institute(@institute)} #{section.section_name}".truncate(30), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, message_categories: "Homework", is_custom_group: false) if !grade.blank? and !section.blank?
                        end
                      end
                      
                    end
                  end
                end
              else

              end

              teachers_sheet = data_file.worksheet("Teachers")
              if(!teachers_sheet.blank?)
                teacher_fields = teachers_sheet.row(0)
                teachers_sheet.rows[1..(teachers_sheet.rows.length-1)].each do |teacher_row|
                  if(!teacher_row.blank?)
                    first_name = teacher_row[0]; first_name = first_name.capitalize if !first_name.blank?
                    last_name = teacher_row[1]; last_name = last_name.capitalize if !last_name.blank?
                    email = teacher_row[2]
                    mobile_no = teacher_row[3]; mobile_no = mobile_no.to_i.to_s if !mobile_no.blank?
                    password = teacher_row[4]; password = password.to_s if !password.blank?; password = Random.new.rand(1000..9999).to_s if password.blank?
                    gender = teacher_row[5]
                    address = teacher_row[6]
                    pincode = teacher_row[7]
                    staff_id = teacher_row[8]
                    classteacher_grade_name = teacher_row[9]
                    classteacher_section_name = teacher_row[10]
                    if(!first_name.blank? or !email.blank? or !mobile_no.blank?)
                      staff = User.new(role: "Teacher")
                      staff.password = password
                      staff.first_name = first_name
                      staff.last_name = last_name
                      staff.mobile_no = mobile_no
                      staff.isd_code = "91"
                      staff.email = email
                      staff.gender = gender
                    
                      staff.address = address
                      staff.pincode = pincode.to_s if !pincode.blank?
                      
                      staff.staff_id = staff_id.to_s if !staff_id.blank?
                      
                      staff.is_registration_complete = true
                    
                      staff.save
                      save_user_password_with_system_encryption_key(staff, password)
                      send_user_account_password_through_email(staff, password) if !staff.email.blank?
                      send_user_account_password_through_sms(staff, password) if !staff.mobile_no.blank?

                      @institute.add_member(staff.id, current_user.id, :Teacher)
                      @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
                      @institute_conversation.add_participant(staff.id, current_user.id) if !@institute_conversation.blank? and !staff.blank? 

                      if(!classteacher_grade_name.blank? and !classteacher_section_name.blank?)
                        grade = @institute.grades.find_by(grade_name: classteacher_grade_name)
                        section = grade.get_sections_for_institute(@institute).find_by(section_name: classteacher_section_name)
                          
                        section.add_member_for_institute_and_grade(@institute, grade, current_user, staff, "Teacher") if !section.blank?
                        section.set_classteacher_for_institute_and_grade(@institute, grade, staff) if !section.blank?
                        section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) if !section.blank?
                        
                        section_conversation.add_participant(staff.id, current_user.id) if !section_conversation.blank? and !section.blank?
                      end
                    end
                    
                  end
                  
                  
                  
                end
              else

              end

              subject_teachers_sheet = data_file.worksheet("Subject Teachers")
              if(!subject_teachers_sheet.blank?)
                subject_teachers_sheet_fields = subject_teachers_sheet.row(0)
                subject_names = subject_teachers_sheet_fields[2..(subject_teachers_sheet_fields.length - 1)].compact
                
                subject_teachers_sheet.rows[1..(class_sheet.rows.length - 1)].compact.each do |subject_teachers_row|
                  
                  grade_name = subject_teachers_row[0]
                  section_name = subject_teachers_row[1]
                  grade = Grade.find_by(grade_name: grade_name)
                  if(!grade_name.blank? and grade.blank?)
                    grade = Grade.create(grade_name: grade_name.strip)
                  end
                  section = Section.find_by(section_name: section_name)
                  if(!section_name.blank? and section.blank?)
                    section = Section.create(section_name: section_name.strip)
                  end

                  subject_names.each do |subject_name|
                    if(!subject_name.blank?)
                      subject = Subject.find_by(subject_name: subject_name)
                      if(subject.blank?)
                        subject = Subject.create(subject_name: subject_name)
                      end
                      if(!subject_teachers_row[subject_teachers_sheet_fields.index(subject_name)].blank?)
                        
                        subject_teacher_first_name = subject_teachers_row[subject_teachers_sheet_fields.index(subject_name)].split(" ").first
                        subject_teacher_last_name = subject_teachers_row[subject_teachers_sheet_fields.index(subject_name)].split(" ").last
                        
                        @institute.institutes_sections_subjects_models.create(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, creator_id: current_user.id) if !grade.blank? and !section.blank? and !subject.blank?
                        subject_conversation = current_user.created_conversations.create(conversation_name: "#{subject.subject_name}, #{grade.custom_name_for_institute(@institute)} #{section.section_name}".truncate(30), institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: subject.id, message_categories: "Homework", is_custom_group: false) if !grade.blank? and !section.blank? and !subject.blank?
                        
                        subject_teacher = @institute.members.find_by(first_name: subject_teacher_first_name, last_name: subject_teacher_last_name, role: "Teacher")
                        if(!subject_teacher.blank?)
                          section_conversation = Conversation.find_by(is_custom_group: false, institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil) 
                          section.add_member_for_institute_and_grade(@institute, grade, current_user, subject_teacher, "Teacher")
                          section.set_subject_teacher_for_institute_and_grade_and_subject(@institute, grade, subject, subject_teacher) if !subject.blank?
                          subject_conversation.add_participant(subject_teacher.id, current_user.id, true) if !subject_conversation.blank? and !subject_teacher.blank?  
                          section_conversation.add_participant(subject_teacher.id, current_user.id, true) if !section_conversation.blank? and !subject_teacher.blank?
                        end
                      
                        
                      end
                    end
                  end
                end
              else

              end

              students_sheet = data_file.worksheet("Students")
              if(!students_sheet.blank?)
                students_fields = students_sheet.row(0)
                students_sheet.rows[1..(students_sheet.rows.length-1)].each do |student_row|
                  if(!student_row.blank?)
                    first_name = student_row[0]; first_name = first_name.capitalize if !first_name.blank?
                    last_name = student_row[1]; last_name = last_name.capitalize if !last_name.blank?
                    email = student_row[2]
                    mobile_no = student_row[3]; mobile_no = mobile_no.to_i.to_s if !mobile_no.blank?
                    password = student_row[4]; password = password.to_s if !password.blank?; password = Random.new.rand(1000..9999).to_s if password.blank?
                    gender = student_row[5]
                    date_of_birth = student_row[6]
                    address = student_row[7]
                    pincode = student_row[8]
                    student_grade_name = student_row[9]
                    student_section_name = student_row[10]
                    roll_no = student_row[11]
                    is_using_transport = student_row[12]
                    fathers_first_name = student_row[13]; fathers_first_name = fathers_first_name.capitalize if !fathers_first_name.blank?
                    fathers_email = student_row[14]; 
                    fathers_mobile_no = student_row[15]; fathers_mobile_no = fathers_mobile_no.to_i.to_s if !fathers_mobile_no.blank?
                    fathers_password = student_row[16]; fathers_password = fathers_password.to_s if !fathers_password.blank?; fathers_password = Random.new.rand(1000..9999).to_s if fathers_password.blank?
                    mothers_first_name = student_row[17]; mothers_first_name = mothers_first_name.capitalize if !mothers_first_name.blank?
                    mothers_email = student_row[18]
                    mothers_mobile_no = student_row[19]; mothers_mobile_no = mothers_mobile_no.to_i.to_s if !mothers_mobile_no.blank?
                    mothers_password = student_row[20]; mothers_password = mothers_password.to_s if !mothers_password.blank?; mothers_password = Random.new.rand(1000..9999).to_s if mothers_password.blank?



                    if(!first_name.blank? or !email.blank? or !mobile_no.blank?)
                      student = User.new(role: "Student")
                      student.password = password
                      student.first_name = first_name
                      student.last_name = last_name
                      student.mobile_no = mobile_no.to_i.to_s 
                      student.isd_code = "91"
                      student.email = email
                      student.gender = gender
                      student.date_of_birth = Time.parse(date_of_birth.to_s) if !date_of_birth.blank?
                      student.address = address
                      student.pincode = pincode.to_s if !pincode.blank?
                            
                      student.roll_no = roll_no.to_s if !roll_no.blank?
                      
                      student.is_registration_complete = true
                    
                      student.save
                      save_user_password_with_system_encryption_key(student, password)
                      send_user_account_password_through_email(student, password) if !student.email.blank?
                      send_user_account_password_through_sms(student, password) if !student.mobile_no.blank?


                      @institute.add_member(student.id, current_user.id, :Student)
                      @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
                      @institute_conversation.add_participant(student.id, current_user.id) if !@institute_conversation.blank? and !student.blank? 

                      father = nil; mother = nil
                      if(!fathers_first_name.blank? or !fathers_email.blank? or !fathers_mobile_no.blank?)
                        father = User.new(role: "Parent")
                        father.password = fathers_password
                        father.first_name = fathers_first_name;
                        father.last_name = last_name
                        father.mobile_no = fathers_mobile_no.to_i.to_s 
                        father.isd_code = "91"
                        father.email = fathers_email
                        father.gender = :male
                      
                        father.address = address
                        father.pincode = pincode.to_s if !pincode.blank?
                        
                        
                        
                        father.is_registration_complete = true
                      
                        father.save
                        save_user_password_with_system_encryption_key(father, fathers_password)
                        send_user_account_password_through_email(father, fathers_password) if !father.email.blank?
                        send_user_account_password_through_sms(father, fathers_password) if !father.mobile_no.blank?

                        @institute.add_member(father.id, current_user.id, :Parent)
                        @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
                        @institute_conversation.add_participant(father.id, current_user.id) if !@institute_conversation.blank? and !father.blank? 

                      end

                      if(!mothers_first_name.blank? or !mothers_email.blank? or !mothers_email.blank?)
                        mother = User.new(role: "Parent")
                        mother.password = mothers_password
                        mother.first_name = mothers_first_name
                        mother.last_name = last_name
                        mother.mobile_no = mothers_mobile_no.to_i.to_s 
                        mother.isd_code = "91"
                        mother.email = mothers_email
                        mother.gender = :female
                      
                        mother.address = address
                        mother.pincode = pincode.to_s if !pincode.blank?
                        mother.is_registration_complete = true
                      
                        mother.save
                        save_user_password_with_system_encryption_key(mother, mothers_password)
                        send_user_account_password_through_email(mother, mothers_password) if !mother.email.blank?
                        send_user_account_password_through_sms(mother, mothers_password) if !mother.mobile_no.blank?

                        @institute.add_member(mother.id, current_user.id, :Parent)
                        @institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil, is_custom_group: false)
                        @institute_conversation.add_participant(mother.id, current_user.id) if !@institute_conversation.blank? and !mother.blank? 

                      end

                      if(!student.blank? and !father.blank?)
                          student.update(father_id: father.id)
                          if(father.child_ids.blank?)
                              father.update(child_ids: student.id.to_s)
                          else
                              father.update(child_ids: father.child_ids + ", " +student.id.to_s)
                          end
                      end

                      if(!student.blank? and !mother.blank?)
                          student.update(mother_id: mother.id)
                          if(mother.child_ids.blank?)
                              mother.update(child_ids: student.id.to_s)
                          else
                              mother.update(child_ids: mother.child_ids + ", " +student.id.to_s)
                          end
                      end
                      if(!student_grade_name.blank? and !student_section_name.blank?)
                        grade = @institute.grades.find_by(grade_name: student_grade_name)
                        section = grade.get_sections_for_institute(@institute).find_by(section_name: student_section_name)
                          
                        section.add_member_for_institute_and_grade(@institute, grade, current_user, student, "Student") if !section.blank?
                        section.add_member_for_institute_and_grade(@institute, grade, current_user, father, "Parent") if !section.blank? and !father.blank?
                        section.add_member_for_institute_and_grade(@institute, grade, current_user, mother, "Parent") if !section.blank? and !mother.blank?
                        
                        section_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: nil, is_custom_group: false) if !section.blank?
                        section_conversation.add_participant(student.id, current_user.id) if !section_conversation.blank? and !section.blank?
                        section_conversation.add_participant(father.id, current_user.id) if !section_conversation.blank? and !section.blank? and !father.blank?
                        section_conversation.add_participant(mother.id, current_user.id) if !section_conversation.blank? and !section.blank? and !mother.blank?

                        sections_subjects = section.sections_subjects.where(institute_id: @institute.id, grade_id: grade.id)
                        sections_subjects.each do |section_subject|
                            subject_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: grade.id, section_id: section.id, subject_id: section_subject.subject_id, is_custom_group: false)
                            subject_conversation.add_participant(student.id, current_user.id) if !subject_conversation.blank?
                            subject_conversation.add_participant(father.id, current_user.id) if !subject_conversation.blank? and !father.blank?
                            subject_conversation.add_participant(mother.id, current_user.id) if !subject_conversation.blank? and !mother.blank?
                        end
                      end
                    end
                    
                    
                  end
                  
                  
                  
                end
              else

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
