class InstituteMember < ApplicationRecord

	belongs_to :member, class_name: :User, foreign_key: :member_id, inverse_of: :members_institutes
	
	belongs_to :institute, class_name: :Institute, foreign_key: :institute_id, inverse_of: :institutes_members

	belongs_to :membership_creator, class_name: :User, foreign_key: :creator_id, inverse_of: :created_institutes_members_models, optional: true
	
end
