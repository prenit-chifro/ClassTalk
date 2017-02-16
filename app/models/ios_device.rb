class IosDevice < ApplicationRecord
	belongs_to :ios_device_user, class_name: :User, foreign_key: :ios_device_user_id, inverse_of: :ios_devices, optional: true
end
