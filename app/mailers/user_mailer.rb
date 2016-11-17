class UserMailer < ApplicationMailer
	
	def send_account_password_through_email user, password
		@user = user
		@user_password = password
		
		@url  = "https://classtalk.in" 
		mail(to: @user.email, subject: "Welcome. Your ClassTalk Account Details:") if !@user.email.blank?
		return		
	end
	
	def publish_notice_email notice, receiver
		@event = event
		@receiver = receiver
		mail(to: receiver.email, subject: "New Notice circulated from your Institute") if !receiver.email.blank?
		return
	end
	
	def publish_event_email event, receiver
		@receiver = receiver
		@event = event
		mail(to: receiver.email, subject: "Your institute added an Event") if !receiver.email.blank?
		return
	end
	
end
