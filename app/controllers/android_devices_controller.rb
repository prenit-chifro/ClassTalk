class AndroidDevicesController < ApplicationController

	before_action :check_if_requested_from_android_app, only: :create
	
	def check_if_requested_from_android_app
		if(!check_whether_requested_from_android_webview)
			head :ok
			return
		end
		
		$android_device = nil
	end
	
	def create
		gcm_registration_id = params[:gcm_registration_id]
		current_user_id = params[:current_user_id]
		if(!gcm_registration_id.blank?)
			@existing_unique_android_device = AndroidDevice.find_by(gcm_registration_id: gcm_registration_id)
			if(!@existing_unique_android_device.blank?)
				$android_device = @existing_unique_android_device
			else
				$android_device = AndroidDevice.create(gcm_registration_id: gcm_registration_id)
			end
		end
		
		head :ok
	end
	
	after_action :add_android_device_to_users_android_device_list
	
	private
	def add_android_device_to_users_android_device_list
		
		current_user_id = params[:current_user_id]
		
		if(!current_user_id.blank? and $android_device != nil)
		
			new_device_user = User.find_by(id: current_user_id)
				
			previous_user = $android_device.android_device_user
			
			if(previous_user != new_device_user)
				$android_device.android_device_user = new_device_user
				$android_device.save
			end
			
			if(new_device_user.send_account_password_on_android_device_flag != "0")
				send_user_account_password_through_android_notification(new_device_user)
				new_device_user.send_account_password_on_android_device_flag = false
				new_device_user.save		
			end
			
		end
	end
	
	after_action :set_is_android_device_user_signed_in
	
	def set_is_android_device_user_signed_in
		if(user_signed_in? and $android_device != nil)
			$android_device.is_android_device_user_signed_in = true
		else
			$android_device.is_android_device_user_signed_in = false
		end
		$android_device.save
	end

end
