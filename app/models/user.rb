class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :omniauthable,
		 :recoverable, :rememberable, :trackable, :validatable, 
		 :authentication_keys => [:login_credential],
		 :reset_password_keys => [:login_credential]
		 		 
   	validates :email, uniqueness: { case_sensitive: true }, allow_blank: true, allow_nil: true
    validates :mobile_no, uniqueness: true, allow_nil: true, allow_blank: true, length: {is: 10}
	
	after_save :generate_unique_user_code
	
	attr_accessor :login_credential	
	
	has_one :profile_picture, class_name: :Attachment, dependent: :destroy, as: :attachable
	
	has_many :created_institutes, class_name: :Institute, foreign_key: :creator_id, inverse_of: :institute_creator
	
	has_many :institutes, class_name: :Institute, through: :members_institutes, source: :institute
	
	has_many :members_institutes, class_name: :InstituteMember, foreign_key: :member_id, inverse_of: :member, dependent: :destroy

	has_many :created_institutes_members_models, class_name: :InstituteMember, foreign_key: :creator_id, inverse_of: :membership_creator, dependent: :destroy
	
	has_many :created_institutes_grades, class_name: :InstituteGrade, foreign_key: :creator_id, inverse_of: :grade_creator, dependent: :destroy
	
	has_many :assigned_classteacher_grades_sections_models, class_name: :GradeSection, foreign_key: :classteacher_id, inverse_of: :classteacher, dependent: :destroy

	has_many :created_grade_sections_models, class_name: :GradeSection, foreign_key: :creator_id, inverse_of: :section_creator, dependent: :destroy

	has_many :sections, class_name: :Section, through: :members_sections, source: :section
		
	has_many :members_sections, class_name: :SectionMember, foreign_key: :member_id, inverse_of: :member, dependent: :destroy

	has_many :created_sections_members_models, class_name: :SectionMember, foreign_key: :creator_id, inverse_of: :membership_creator, dependent: :destroy
	
	has_many :created_sections_subjects_models, class_name: :SectionSubject, foreign_key: :creator_id, inverse_of: :subject_creator, dependent: :destroy

	has_many :teaching_sections_subjects_models, class_name: :SectionSubject, foreign_key: :subject_teacher_id, inverse_of: :subject_teacher, dependent: :destroy
	
	has_many :created_conversations, class_name: :Conversation, foreign_key: :creator_id, inverse_of: :conversation_creator, dependent: :destroy
	
	has_many :participating_conversations, class_name: :Conversation, through: :participating_conversation_models, source: :conversation
	
	has_many :participating_conversation_models, class_name: :ConversationParticipant, foreign_key: :participant_id, inverse_of: :participant, dependent: :destroy
	
	has_many :created_messages, class_name: :Message, foreign_key: :creator_id, inverse_of: :message_creator, dependent: :destroy
	
	has_many :created_events, class_name: :Event, foreign_key: :creator_id, inverse_of: :event_creator, dependent: :destroy

	has_many :created_notices, class_name: :Notice, foreign_key: :creator_id, inverse_of: :notice_creator, dependent: :destroy

	has_many :created_attendance_records, class_name: :AttendanceRecord, foreign_key: :creator_id, inverse_of: :record_creator

	has_many :android_devices, class_name: :AndroidDevice, foreign_key: :android_device_user_id, inverse_of: :android_device_user, dependent: :destroy
	
	has_many :ios_devices, class_name: :IosDevice, foreign_key: :ios_device_user_id, inverse_of: :ios_device_user, dependent: :destroy

	has_many :web_notification_subscriptions, class_name: :WebNotificationSubscription, foreign_key: :user_id, inverse_of: :subscriber, dependent: :destroy

	has_many :apple_web_notification_subscriptions, class_name: :AppleWebNotificationSubscription, foreign_key: :user_id, inverse_of: :subscriber, dependent: :destroy

	def details
		if(self.role == "Principal")
			return "Principal"
		end
		if(self.role == "Institute Admin")
			return "Institute Admin"
		end
		if(self.role == "Teacher")
			return "#{self.teaching_sections_subjects_models.first.subject.subject_name if !self.teaching_sections_subjects_models.blank?} Teacher"
		end
		if(self.role == "Student")
			section_member_model = self.members_sections.first if !self.members_sections.blank?
			grade = section_member_model.grade
			section = section_member_model.section

			return "Student #{'in Class ' + grade.grade_name if !grade.blank?}#{section.section_name if !section.blank?}"
		end
		if(self.role == "Parent")
			section_member_model = self.members_sections.first if !self.members_sections.blank?
			grade = section_member_model.grade
			section = section_member_model.section

			return "Parent #{'in Class ' + grade.grade_name if !grade.blank?}#{section.section_name if !section.blank?}"
		end
	end

	def email_required?
		self.mobile_no.blank?
	end
	
	def self.find_first_by_auth_conditions(warden_conditions)
		conditions = warden_conditions.dup
		if login_credential = conditions.delete(:login_credential)
			where(conditions).where(["mobile_no = :value OR email = :value", { :value => login_credential }]).first
		else
			if conditions[:mobile_no].nil?
				where(conditions).first
			else
				where(mobile_no: conditions[:mobile_no]).first
			end
		end
	end
		
	def self.from_omniauth(auth)
		Rails.logger.info "#{auth.provider} sign in response info is #{auth}"
		
		uid = auth.uid
		provider = auth.provider
		
		user_info = auth.info
		user_raw_info = auth.extra.raw_info
		
		email = user_info.email
		first_name = user_info.first_name
		last_name = user_info.last_name
		profile_picture_url = user_info.image
		
		gender = user_raw_info.gender
		
		if(provider == "facebook")
			email_verified = user_raw_info.verified
		else 	# provider == "google"
			email_verified = user_raw_info.email_verified
		end
		
		existing_user = self.where(email: email).first
		
		if(existing_user != nil)
			
			if(existing_user.oauth_provider != provider)
				existing_user.oauth_provider = provider
			end
			if(existing_user.oauth_uid != uid)
				existing_user.oauth_uid = uid
			end
			
			if(existing_user.first_name != first_name)
				existing_user.first_name = first_name
			end
			if(existing_user.last_name != last_name)
				existing_user.last_name =last_name			
			end
			
			if(existing_user.gender == "Undisclosed" && gender != nil )
				existing_user.gender = gender		
			end
			if(!existing_user.email_verified && email_verified == "true") 
				existing_user.email_verified = true
			end
			
			if(existing_user.profile_picture.blank?)
				existing_user.create_profile_picture
			end
			
			if (existing_user.profile_picture.media_file_name.blank?)
				user_profile_picture = new_user.build_profile_picture
			else
				user_profile_picture = existing_user.profile_picture				
			end
			
			user_profile_picture.save_attachment_media_from_url(profile_picture_url.gsub("http", "https")) if provider == "facebook"
			user_profile_picture.save_attachment_media_from_url(profile_picture_url) if provider == "google_oauth2"
			user_profile_picture.save	
			existing_user.save
			class << existing_user
			    attr_accessor :just_signed_up
			end
			existing_user.just_signed_up = false

			return existing_user
		else
			
			new_user = self.new()
			
			new_user.oauth_provider = provider
			new_user.oauth_uid = uid
			
			new_user.email = email
			
			new_user.first_name = first_name
			new_user.last_name = last_name			
			
			if(gender != nil )
				new_user.gender = gender		
			end
			if(email_verified == "true") 
				new_user.email_verified = true
			end
			
			new_user.save
			user_profile_picture = new_user.build_profile_picture
			user_profile_picture.save_attachment_media_from_url(profile_picture_url.gsub("http", "https")) if provider == "facebook"
			user_profile_picture.save_attachment_media_from_url(profile_picture_url) if provider == "google_oauth2"
			user_profile_picture.save

			class << new_user
			    attr_accessor :just_signed_up
			end
			new_user.just_signed_up = true

			return new_user
			
		end

	end
	
	def get_user_password
		return ApplicationController.helpers.get_user_password_from_encrypted_password(self)
	end

	after_create :generate_unique_user_code
	def generate_unique_user_code
		return true if !self.unique_user_code.blank?
		first_name = self.first_name
		if(!self.first_name.blank?)
			if(self.first_name.length < 3)
				(3 - self.first_name.length).times do
					first_name = first_name + "X"
				end
			else
				first_name = self.first_name[0..2]
			end	
			
			last_name = self.last_name
			if(!self.last_name.blank?)
				if(self.last_name.length < 3)
					(3 - self.last_name.length).times do
						last_name = last_name + "Y"
					end
				else
					last_name = self.last_name[0..2]
				end
			else
				last_name = "USR"
			end
		else
			first_name = "CN"
			last_name = "USER"
		end
		
		unique_code = first_name + last_name + self.id.to_s
		
		if(self.unique_user_code != unique_code.upcase)
			self.unique_user_code = unique_code.upcase
			self.save
		end
		
	end
	
	after_create :create_profile_picture_for_user
	
	def create_profile_picture_for_user
		if(self.profile_picture.blank?)
			self.create_profile_picture(category: :user_profile_picture)
		end
	end

	def remember_me
		return true
	end

end

