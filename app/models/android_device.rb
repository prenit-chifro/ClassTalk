class AndroidDevice < ActiveRecord::Base
	
	belongs_to :android_device_user, class_name: :User, inverse_of: :android_devices, optional: true 
	
end
