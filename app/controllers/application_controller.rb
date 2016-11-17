class ApplicationController < ActionController::Base
	
	include ApplicationHelper

	protect_from_forgery with: :exception

	layout :layout_by_resource

	before_action :configure_permitted_login_parameters, if: :devise_controller?

	# before_action: check for Login when a request come
	before_action :check_login
	
	private # before_action :check_login
	def check_login
		if(params[:controller] != nil)
			if(params[:controller].include?("my_devise") or params[:controller].include?("android_devices") or params[:controller].include?("safari_web_push"))
				Rails.logger.debug "BeforeFilter: Login is not required with this request"
			else
				if(user_signed_in?)
					Rails.logger.debug "BeforeFilter: User Signed In. Login is not required"
					
					if(!current_user.is_registration_complete and request.fullpath != complete_registration_user_path(current_user))
						redirect_to complete_registration_user_path(current_user)
					end
					@institute = current_user.institutes.first
					@institute_conversation = Conversation.find_by(institute_id: @institute.id, grade_id: nil, section_id: nil, subject_id: nil) if !@institute.blank?
				else
					authenticate_user!
				end
			end
		end		
	end
	

	#before_action: store last url for redirection and other things 
	before_action :store_location
	
	private #before_action :store_location
	def store_location 
		# store last url - this is needed for post-login redirect to whatever the user last visited.
		
		if(session[:navigable_previous_url] == nil)
			Rails.logger.debug "BeforeFilter store_location: session[:navigable_previous_url] is NULL. Setting it to '/'"  
			session[:navigable_previous_url] = "/"
		end
		
		if(session[:previous_url] == nil)
			Rails.logger.debug "BeforeFilter store_location: session[:previous_url] is NULL. Setting it to '/'"  
			session[:previous_url] = "/"
		end
		
		if(request.get?)
			Rails.logger.debug "BeforeFilter store_location: GET Request with request url = " + request.fullpath
			Rails.logger.debug "BeforeFilter store_location: Last Saved session[:navigable_previous_url] is " + session[:navigable_previous_url]
			Rails.logger.debug "BeforeFilter store_location: Last Saved session[:previous_url] is " + session[:previous_url]
			
			if(params[:controller] != nil)
				if ( params[:controller].include?("my_device"))				
					
					Rails.logger.debug "BeforeFilter store_location: In Login Page."
					Rails.logger.debug "BeforeFilter store_location: NOT Modifying session[:navigable_previous_url]."
					
					session[:previous_url] = request.fullpath
					Rails.logger.debug "BeforeFilter store_location: Modified session[:previous_url] = " + session[:previous_url]
				
				else
					
					session[:previous_url] = request.fullpath
					session[:navigable_previous_url] = request.fullpath
					
					Rails.logger.debug "BeforeFilter store_location: Not In Login Page."
					Rails.logger.debug "BeforeFilter store_location: Modified session[:previous_url] = " + session[:previous_url]
					Rails.logger.debug "BeforeFilter store_location: Modified session[:navigable_previous_url] = " + session[:navigable_previous_url]
					
				end
			end
			
		else
			Rails.logger.debug "BeforeFilter: POST Request with request url = " + request.fullpath
			Rails.logger.debug "BeforeFilter: session[:previous_url] = #{session[:previous_url]} and session[:navigable_previous_url] = #{session[:navigable_previous_url]}  Not Modified"
		end
		
	end
	
	# method to ckeck native android app requests and use this method in views
	def check_whether_requested_from_android_webview
		user_agent = request.user_agent
		if(user_agent.include?("CLASSTALK_ANDROID_APP"))
			return true
		else
			return false
		end
	end
	helper_method :check_whether_requested_from_android_webview

	def check_whether_requested_from_ios_webview
		user_agent = request.user_agent
		if(user_agent.include?("CLASSTALK_IOS_APP"))
			return true
		else
			return false
		end
	end
	helper_method :check_whether_requested_from_ios_webview

	def set_send_gcm_registration_id_to_backend_flag value
		session[:send_gcm_registration_id_to_backend_flag] = value
	end
	
	def get_send_gcm_registration_id_to_backend_flag
		if(session[:send_gcm_registration_id_to_backend_flag])
			return session[:send_gcm_registration_id_to_backend_flag] 
		end
		return false
	end
	
	def set_send_android_gcm_registration_id_flag_in_header
		response.headers['X-Send-Android-GCM-Registration-Id-Flag'] = "TRUE"
	end
	
	def set_send_ios_device_token_to_backend_flag value
		session[:send_ios_device_token_to_backend_flag] = value
	end
	
	def get_send_ios_device_token_to_backend_flag
		if(session[:send_ios_device_token_to_backend_flag])
			return session[:send_ios_device_token_to_backend_flag]
		end
		return false
	end
	
	def set_send_android_gcm_registration_id_flag_in_header
		response.headers['X-Send-Ios-Deivce-Token-Flag'] = "TRUE"
	end

	def set_send_current_user_id_in_header_flag flag, value
		session[:send_current_user_id_in_header_flag] = flag
		session[:current_user_id] = value
	end
	
	def get_send_current_user_id_in_header_flag
		if(session[:send_current_user_id_in_header_flag])
			return session[:send_current_user_id_in_header_flag] 
		end
		return false
	end
	
	def set_current_user_id_in_header
		response.headers['X-Current-User-Id'] = session[:current_user_id]
	end

	def configure_permitted_login_parameters
		devise_parameter_sanitizer.permit :sign_up, keys: [:email, :isd_code, :mobile_no, :password, :password_confirmation, :first_name, :last_name, :role, :gender]
		devise_parameter_sanitizer.permit :sign_in, keys: [:email, :isd_code, :mobile_no, :login_credential, :password, :remember_me]
		devise_parameter_sanitizer.permit :account_update, keys: [:email, :isd_code, :mobile_no, :login_credential, :password, :password_confirmation, :current_password]
	end

	# after_action: set CSRF TOKEN after ajax requests 
	after_action :set_csfr_token_for_ajax_requests
		
	private # after_action :set_csfr_token_and_current_url_and_flash_messages_for_ajax_requests
	def set_csfr_token_for_ajax_requests
		if(request.xhr?)
			Rails.logger.debug "AfterFilter: XHR #{request.method} REQUEST: with request url = " + request.fullpath 	
			
			# Add the newly created csrf token to the page headers
			response.headers['X-CSRF-Token'] = "#{form_authenticity_token}"
						
			Rails.logger.debug "AfterFilter: Attached and Sending CSRF Token in Response Header."
			
			# Discard flash if not redirecting
			if(response.status != 302)
				flash.discard
			end
			
		end
	end
	
	# after_action: check if send gcm registration id flag in header
	after_action :check_send_gcm_registration_id_to_backend_flag
	
	private # after_action :check_send_gcm_registration_id_to_backend_flag
	def check_send_gcm_registration_id_to_backend_flag
		if(get_send_gcm_registration_id_to_backend_flag)
			set_send_android_gcm_registration_id_flag_in_header
			Rails.logger.debug "after_action: attached send_gcm_registration_id_to_backend_flag in header."
			
			if(response.status != 302)
				set_send_gcm_registration_id_to_backend_flag(false)
				Rails.logger.debug "after_action: Changed Flag value. send_gcm_registration_id_to_backend_flag = false"
			end	
		end
	end
	
	# after_action check if send current user id in header 
	after_action :check_send_current_user_id_in_header
	
	private # after_action :check_send_current_user_id_in_header
	def check_send_current_user_id_in_header
		if(get_send_current_user_id_in_header_flag)
			set_current_user_id_in_header
			Rails.logger.debug "after_action: attached current user id in header."
		end
		
		if(response.status != 302)
			set_send_current_user_id_in_header_flag(false, "")
			Rails.logger.debug "after_action: Changed Flag value. send_current_user_id_in_header_flag = false"
		end	
	end

	# after_action: set CSRF TOKEN after ajax requests 
	after_action :set_csfr_token_for_ajax_requests
		
	private # after_action :set_csfr_token_and_current_url_and_flash_messages_for_ajax_requests
	def set_csfr_token_for_ajax_requests
		if(request.xhr?)
			Rails.logger.debug "AfterFilter: XHR #{request.method} REQUEST: with request url = " + request.fullpath 	
			
			# Add the newly created csrf token to the page headers
			response.headers['X-CSRF-Token'] = "#{form_authenticity_token}"
						
			Rails.logger.debug "AfterFilter: Attached and Sending CSRF Token in Response Header."
			
			# Discard flash if not redirecting
			if(response.status != 302)
				flash.discard
			end
			
		end
	end
	
	# after_action: check if send gcm registration id flag in header
	after_action :check_send_gcm_registration_id_to_backend_flag
	
	private # after_action :check_send_gcm_registration_id_to_backend_flag
	def check_send_gcm_registration_id_to_backend_flag
		if(get_send_gcm_registration_id_to_backend_flag)
			set_send_android_gcm_registration_id_flag_in_header
			Rails.logger.debug "after_action: attached send_gcm_registration_id_to_backend_flag in header."
			
			if(response.status != 302)
				set_send_gcm_registration_id_to_backend_flag(false)
				Rails.logger.debug "after_action: Changed Flag value. send_gcm_registration_id_to_backend_flag = false"
			end	
		end
	end
	
	# after_action check if send current user id in header 
	after_action :check_send_current_user_id_in_header
	
	private # after_action :check_send_current_user_id_in_header
	def check_send_current_user_id_in_header
		if(get_send_current_user_id_in_header_flag)
			set_current_user_id_in_header
			Rails.logger.debug "after_action: attached current user id in header."
		end
		
		if(response.status != 302)
			set_send_current_user_id_in_header_flag(false, "")
			Rails.logger.debug "after_action: Changed Flag value. send_current_user_id_in_header_flag = false"
		end	
	end

	def layout_by_resource
	    if params[:controller].include?("my_devise")
	      "devise"
	    else
	      "application"
	    end
  	end

	    
end
