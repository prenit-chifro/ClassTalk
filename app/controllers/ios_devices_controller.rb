class IosDevicesController < ApplicationController

	before_action :check_if_requested_from_ios_app
	
	def check_if_requested_from_ios_app
		if(!check_whether_requested_from_ios_webview)
			head :ok
			return
		end
		
		$ios_device = nil
	end
	
	def create
		ios_device_token = params[:ios_device_token]
		
		if(!ios_device_token.blank?)
			@existing_unique_ios_device = IosDevice.find_by(ios_device_token: ios_device_token)
			if(!@existing_unique_ios_device.blank?)
				$ios_device = @existing_unique_ios_device
			else
				$ios_device = IosDevice.create(ios_device_token: ios_device_token)
			end
		end
		
		head :ok
	end
	
	after_action :add_ios_device_to_users_ios_device_list
	
	private
	def add_ios_device_to_users_ios_device_list
		
		current_user_id = params[:current_user_id]
		
		if(!current_user_id.blank? and $ios_device != nil)
		
			new_device_user = User.find_by(id: current_user_id)
				
			previous_user = $ios_device.ios_device_user
			
			if(previous_user != new_device_user)
				$ios_device.ios_device_user = new_device_user
				$ios_device.save
			end
			
			if(new_device_user.send_account_password_on_android_device_flag != "0")
				send_user_account_password_through_android_notification(new_device_user)
				new_device_user.send_account_password_on_android_device_flag = false
				new_device_user.save		
			end
			
		end
	end
	
	after_action :set_is_ios_device_user_signed_in
	
	def set_is_ios_device_user_signed_in
		if(user_signed_in? and $ios_device != nil)
			$ios_device.is_ios_device_user_signed_in = true
		else
			$ios_device.is_ios_device_user_signed_in = false
		end
		$ios_device.save
	end

end
