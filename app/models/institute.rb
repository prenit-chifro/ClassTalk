class Institute < ApplicationRecord

	belongs_to :institute_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_institutes
	
	has_many :members, class_name: :User, through: :institutes_members, source: :member

	has_many :institutes_members, class_name: :InstituteMember, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy
	
	has_many :grades, class_name: :Grade, through: :institutes_grades, source: :grade
	
	has_many :institutes_grades, class_name: :InstituteGrade, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy
	
	has_many :institutes_grades_sections_models, class_name: :GradeSection, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy
	
	has_many :institutes_sections_members_models, class_name: :SectionMember, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy

	has_many :institutes_sections_subjects_models, class_name: :SectionSubject, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy

	has_many :events, class_name: :Event, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy

	has_many :notices, class_name: :Notice, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy
	
	has_one :location, class_name: :Location, as: :locatable, dependent: :destroy

	has_many :attendance_records, class_name: :AttendanceRecord, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy
	
	has_many :timetable_slots, class_name: :TimetableSlot, foreign_key: :institute_id, inverse_of: :institute, dependent: :destroy

	has_one :institute_data_file, class_name: :Attachment, dependent: :destroy, as: :attachable

	def short_name
		non_text_characterless_string = self.institute_name.gsub(/[^0-9a-z ]/i, '')
		split_array = non_text_characterless_string.split(" ")
		short_name_string = ""
		split_array.first(4) do |string|
			if(string == string.upcase)
				short_name_string = short_name_string + string + " "
			else
				short_name_string = short_name_string + string[0].upcase + "."
			end
		end
		return short_name_string
	end

	def chech_if_member user_id
		return self.institutes_members.map{|structure| structure.member_id}.include?(user_id)
	end

	def add_member member_id, adder_id, role
		if(!self.chech_if_member(member_id))
			self.institutes_members.create(member_id: member_id, creator_id: adder_id, role_in_institute: role)	
		end	
	end
	
	def check_if_institute_creator member
		return self.creator_id == member.id
	end
	
	def get_membership_model member
		return self.institutes_members.find_by(member_id: member.id)
	end

	def get_members_role_in_institute member
		return self.get_membership_model(member).role_in_institute
	end

	def get_other_members_for_user user
		member_role = self.get_members_role_in_institute(user)
		if(member_role == "Student" or member_role == "Parent")
			self.get_members_with_given_roles(["Principal", "Institute Admin", "Teacher"])
		else
			self.get_members_with_given_roles(["Principal", "Institute Admin", "Teacher", "Student", "Parent"])
		end
	end
	
	def get_members_with_given_roles roles
		return self.institutes_members.where(role_in_institute: roles).map{|im| im.member}
	end

	after_create :generate_unique_institute_code
	
	def generate_unique_institute_code
		institute_name = self.institute_name
		if(self.institute_name.length < 3)
			(3 - self.institute_name.length).times do
				institute_name = institute_name + "X"
			end
		else
			institute_name = self.institute_name[0..2]
		end
		
		unique_code = "CN" + institute_name + self.id.to_s
		if(self.unique_institute_code != unique_code.upcase)
			self.unique_institute_code = unique_code.upcase
			self.save
		end
		
	end

	after_create :add_creator_as_admin
	
	def add_creator_as_admin
		self.institutes_members.create(member_id: self.creator_id, role_in_institute: "Institute Admin", creator_id: self.creator_id)
	end
end
