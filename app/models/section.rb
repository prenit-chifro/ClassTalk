class Section < ApplicationRecord

	has_many :grades, class_name: :Grade, through: :sections_grades, source: :grade
	
	has_many :sections_grades, class_name: :GradeSection, foreign_key: :section_id, inverse_of: :section, dependent: :destroy

	has_many :subjects, class_name: :Subject, through: :sections_subjects, source: :subject
	
	has_many :sections_subjects, class_name: :SectionSubject, foreign_key: :section_id, inverse_of: :section, dependent: :destroy

	has_many :members, class_name: :User, through: :sections_members, source: :member
	
	has_many :sections_members, class_name: :SectionMember, foreign_key: :section_id, inverse_of: :section, dependent: :destroy

	def get_classteacher_for_institute_and_grade institute, grade
		self.sections_grades.find_by(institute_id: institute.id, grade_id: grade.id).classteacher
	end
	
	def set_classteacher_for_institute_and_grade institute, grade, classteacher
		self.sections_grades.find_by(institute_id: institute.id, grade_id: grade.id).update(classteacher_id: classteacher.id) if self.sections_grades.find_by(institute_id: institute.id, grade_id: grade.id).classteacher_id != classteacher.id
	end
		
	def get_subjects_for_institute_and_grade institute, grade
		Subject.where(id: self.sections_subjects.where(institute_id: institute.id, grade_id: grade.id).map(&:subject_id))
	end
	
	def add_subject_for_institute_and_grade institute, grade, subject, subject_creator
		self.sections_subjects.create(institute_id: institute.id, grade_id: grade.id, subject_id: subject.id, creator_id: subject_creator.id)
	end	
	
	def get_subject_teacher_for_institute_and_grade institute, grade, subject
		self.sections_subjects.find_by(institute_id: institute.id, grade_id: grade.id, subject_id: subject.id).subject_teacher
	end
	
	def set_subject_teacher_for_institute_and_grade_and_subject institute, grade, subject, subject_teacher
		section_subject_modal = self.sections_subjects.find_by(institute_id: institute.id, grade_id: grade.id, subject_id: subject.id)
		section_subject_modal.update(subject_teacher_id: subject_teacher.id) if !section_subject_modal.blank? and section_subject_modal.subject_teacher_id != subject_teacher.id
	end
	
	def get_subject_for_institute_and_grade_and_teacher institute, grade, teacher
		sections_subjects_model = self.sections_subjects.find_by(institute_id: institute.id, grade_id: grade.id, subject_teacher_id: teacher.id)
		sections_subjects_model.subject if !sections_subjects_model.blank?
	end
	
	def get_members_for_institute_and_grade institute, grade
		User.where(id: self.sections_members.where(institute_id: institute.id, grade_id: grade.id).map(&:member_id))
	end
	
	def add_member_for_institute_and_grade institute, grade, membership_creator, member, member_role 
		if(self.sections_members.find_by(institute_id: institute.id, grade_id: grade.id, member_id: member.id, member_role: member_role).blank?)
			self.sections_members.create(institute_id: institute.id, grade_id: grade.id, creator_id: membership_creator.id, member_id: member.id, member_role: member_role)
		end	
	end
		
	def get_members_role_for_institute_and_grade institute, grade, member
		section_member_model = self.sections_members.find_by(institute_id: institute.id, grade_id: grade.id, member_id: member.id)
		section_member_model.member_role if !section_member_model.blank?
	end
	
	def set_members_role_for_institute_and_grade institute, grade, member, role
		section_member_model = self.sections_members.find_by(institute_id: institute.id, grade_id: grade.id, member_id: member.id)
		section_member_model.update(member_role: role)  if !section_member_model.blank? and section_member_model.member_role != role
	end

	def get_members_with_given_roles_for_institute_and_grade_with_role institute, grade, roles
		section_member_models = self.sections_members.where(institute_id: institute.id, grade_id: grade.id, member_role: roles)
		section_member_models.map(&:member)
	end

	def get_other_members_for_institute_grade_and_user institute, grade, user
		users_role = self.get_members_role_for_institute_and_grade(institute, grade, user)

		Rails.logger.debug "========================= user_role = #{users_role}"

		if(users_role == "Parent" or users_role == "Student")
			teachers_admin_principal = self.get_members_with_given_roles_for_institute_and_grade_with_role(institute, grade, ["Teacher", "Institute Admin", "Principal"])
			teachers_admin_principal
		else
			teachers_students_parents_admin_principal = self.get_members_with_given_roles_for_institute_and_grade_with_role(institute, grade, ["Teacher", "Student", "Parent", "Institute Admin", "Principal"])
			all_members = teachers_students_parents_admin_principal - [user]
			all_members
		end

	end 
	
	def get_other_members_for_user user
		section_member_model = self.sections_members.find_by(member_id: user.id)
		institute = section_member_model.institute
		grade = section_member_model.grade
		self.get_other_members_for_institute_grade_and_user(institute, grade, user)
	end

	def get_section_creator_for_institute_and_grade institute, grade
		self.sections_grades.find_by(institute_id: institute.id, grade_id: grade.id).section_creator
	end

end
