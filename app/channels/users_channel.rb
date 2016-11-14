class UsersChannel < ApplicationCable::Channel  
	include ApplicationHelper
	
	def subscribed
		stream_from "/users/#{params[:user_id]}"
		set_users_online_status(current_user, true) if current_user
	end
	
	def unsubscribed
		set_users_online_status(current_user, false)
	end
	
	def set_users_online_status user, status
		if(user.is_online != status)
			user.update(is_online: status)
		end
	end
	
end