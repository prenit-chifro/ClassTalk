module ApplicationHelper

	def publish_message_on_android_notification message, conversation
		@other_participants = conversation.other_participants(message.message_creator)
		participants_android_devices = []
		@other_participants.each do |p|
			participant_android_devices = p.android_devices
			if(!participant_android_devices.blank?)
				participant_android_devices.each do |d|
					participants_android_devices << d
				end
			end
			
			notification = AndroidNotification.new
			notification.title = "#{message.category if message.category!= "Messages"}#{'Message' if message.category== "Messages"} from #{message.message_creator.details.truncate(15)}"
			notification.target_url = "https://classtalk.in/conversations/#{conversation.id}"
			notification.image_url = "https://classtalk.in#{message.message_creator.profile_picture.media.url(:thumb)}"
			if(!message.attachments.blank?)
				attachment = message.attachments.first
				
				if(attachment.is_image_type?)
					notification.message = "#{message.message_creator.first_name}: " + "New Image"
					notification.big_image_url = "https://classtalk.in#{attachment.media.url(:thumb)}"
				elsif(attachment.is_video_type?)	
					notification.message = "#{message.message_creator.first_name}: " + "New Video"
					notification.big_image_url = "https://classtalk.in#{attachment.media.url(:thumb)}"
				elsif(attachment.is_document_type?)
					notification.message = "#{message.message_creator.first_name}: " + "New Document"
				end

				
			end	
			
			if(notification.message.blank?)
				notification.message = "#{message.message_creator.first_name}: " + message.content if notification.message.blank?
			end
			
			notification.save
			
			android_device_ids = participants_android_devices.map{|d| d.gcm_registration_id}
			send_gcm_notification(notification, android_device_ids)

			ios_devices = p.ios_devices.where(is_ios_device_user_signed_in: true)
			if(!ios_devices.blank?)
				send_ios_notification(notification, ios_devices.map(&:ios_device_token))
			end
			
			web_notification = {title: notification.title, body: notification.message, icon: notification.image_url, target_url: notification.target_url}
			publish_web_notification(p, web_notification)
			
		end
	end


	def publish_to channel, script_string
		ActionCable.server.broadcast channel, published_script: script_string
	end
		
	def render_to_string_anywhere partial_path, locals
		return rendered_string = ApplicationController.renderer.render(partial: partial_path, locals: locals)
	end
	
## -------- Methods To Send User Account Password Start Here --------- ##		

	# To send user account password through email
	def send_user_account_password_through_email user, password 
		UserMailer.send_account_password_through_email(user, password).deliver_now
	end
	
	# To send user account password through sms
	def send_user_account_password_through_sms user, password
		user_isd_code = user.isd_code
		user_mobile_no = user.mobile_no
		password_message = "Your ClassNest account password is #{password}. Change it at https://classnest.co/users/password/edit"
		send_sms(password_message, user_isd_code, user_mobile_no)
	end
	
	# To send user account password through android notification
	def send_user_account_password_through_android_notification user

		user_password = get_user_password_from_encrypted_password(user)
			
		password_notification = AndroidNotification.new
		password_notification.title = "Welcome. ClassTalk account password is #{user_password}"
		password_notification.message = user_password
		password_notification.target_url = "https://classtalk.in"
		
		android_devices = user.android_devices.where(is_android_device_user_signed_in: true)
		if(!android_devices.blank?)
			
			if(password_notification.save)
				send_gcm_notification(password_notification, android_devices.map(&:gcm_registration_id))
			end
		end
		
		ios_devices = user.ios_devices.where(is_ios_device_user_signed_in: true)
		if(!ios_devices.blank?)
			
			if(password_notification.save)
				send_ios_notification(password_notification, ios_devices.map(&:ios_device_token))
			end
		end
		
	end

## -------- Methods To Send User Account Password End Here --------- ##			
	
	# To Send SMS 
	def send_sms message, isd_code, mobile_no
		require 'net/http'
		sms_api_url = "http://193.105.74.159/api/v3/sendsms/plain"
		sms_api_params = URI.encode("user=kapsystem&password=kap@user&sender=KAPNFO&SMSText=#{message}&type=longsms&GSM=#{isd_code}#{mobile_no}")
		url = URI.parse(sms_api_url + "?" + sms_api_params)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|https|
			https.request(req)
		}
		Rails.logger.debug "SMS Response:" + res.body
	end
		
	
	# To Send Gcm Notifications on android devices
	def send_gcm_notification notification, android_device_ids
		
		if !Rpush::Gcm::App.find_by_name("CLASSTALK")
			app = Rpush::Gcm::App.new
			app.name = "CLASSTALK"
			app.auth_key = "AIzaSyDFxDdmL5lXZhmnxYTE3jmS7upDrkQSIAw"
			app.connections = 1
			app.save!
		end
		
		if(!android_device_ids.kind_of?(Array))
			android_device_ids = [android_device_ids]
		end
		
		android_device_ids_by_1000 = android_device_ids.each_slice(1000).to_a
		android_device_ids_by_1000.each do |ids|
			ids=ids.uniq
			n = Rpush::Gcm::Notification.new
			n.app = Rpush::Gcm::App.find_by_name("CLASSTALK")
			n.registration_ids = ids
			n.data = notification.as_json
			n.save!
		end
	end
	
	# To Send iOS Notifications on iOS devices
	def send_ios_notification notification, ios_device_tokens
		
		if !Rpush::Apns::App.find_by_name("CLASSTALK_DEV")
			cert_file = File.join(Rails.root, 'ssl', 'ClassTalk_development_APN_Certificate.pem')

			app = Rpush::Apns::App.new
			app.name = "CLASSTALK_DEV"
			app.certificate = File.read(cert_file)
			app.environment = "sandbox" # APNs environment.
			app.connections = 1
			app.save!
		end
		
		if(!ios_device_tokens.kind_of?(Array))
			ios_device_tokens = [ios_device_tokens]
		end
		
		ios_device_tokens_by_1000 = ios_device_tokens.each_slice(1000).to_a
		ios_device_tokens_by_1000.each do |tokens|
			tokens = tokens.uniq
			tokens.each do |token|
				n = Rpush::Apns::Notification.new
				n.app = Rpush::Apns::App.find_by_name("CLASSTALK_DEV")
				n.device_token = token # 64-character hex string
				n.alert = notification.title
				n.badge = notification.id
				n.sound = 'default'
				n.data = notification.as_json
				n.save!
			end
			
		end
	end

	def send_safari_notification notification, ios_device_tokens
		
		if !Rpush::Apns::App.find_by_name("CLASSTALK_SAFARI_PUSH")
			cert_file = File.join(Rails.root, 'ssl', 'ClassTalk_web_push_pem_Certificate.pem')

			app = Rpush::Apns::App.new
			app.name = "CLASSTALK_SAFARI_PUSH"
			app.certificate = File.read(cert_file)
			app.environment = "production" # APNs environment.
			app.connections = 1
			app.save!
		end
		
		if(!ios_device_tokens.kind_of?(Array))
			ios_device_tokens = [ios_device_tokens]
		end
		
		ios_device_tokens_by_1000 = ios_device_tokens.each_slice(1000).to_a
		ios_device_tokens_by_1000.each do |tokens|
			tokens = tokens.uniq
			tokens.each do |token|
				n = Rpush::Apns::Notification.new
				n.app = Rpush::Apns::App.find_by_name("CLASSTALK_SAFARI_PUSH")
				n.device_token = token # 64-character hex string
				n.alert = notification.title
				n.badge = notification.id
				n.sound = 'default'
				n.data = notification.as_json
				n.save!
			end
			
		end
	end
	
	
	def publish_web_notification user, web_notification
		
		user_web_notification_subscriptions = user.web_notification_subscriptions
		user_web_notification_subscriptions.each do |subscription|
			resp = Webpush.payload_send({message: JSON.generate(web_notification), endpoint: subscription.endpoint, auth: subscription.auth, p256dh: subscription.p256dh, api_key: "AIzaSyDFxDdmL5lXZhmnxYTE3jmS7upDrkQSIAw"})
			Rails.logger.debug "======================== response from web push: #{resp.inspect} ============================="
			if( resp.is_a?(Net::HTTPGone) || (resp.is_a?(Net::HTTPBadRequest)) )
				Rails.logger.debug "========================= BAD RESPONSE FROM from web push. destroying subscrition ==========================="
				subscription.destroy
			end
		end
	end
	
	# Save encrypted user password with encryption key and iv	
	def save_user_password_with_system_encryption_key user, password
		require 'openssl'
		require 'digest/sha1'

		# create the cipher for encrypting
		cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		cipher.encrypt

		# you will need to store these for later, in order to decrypt your data
		system_password_encryption_key_ascii = cipher.random_key
		system_password_encryption_iv_ascii = cipher.random_iv
		
		# convert these ascii-8bit keys into utf-8 
		system_password_encryption_key_utf = convert_ascii8bit_to_utf8(system_password_encryption_key_ascii)
		system_password_encryption_iv_utf = convert_ascii8bit_to_utf8(system_password_encryption_iv_ascii)
		
		# save these encryption utf-8 keys in user model for later password decryption
		user.system_password_encryption_key = system_password_encryption_key_utf
		user.system_password_encryption_iv = system_password_encryption_iv_utf
		
		# load them into the cipher
		cipher.key = system_password_encryption_key_ascii
		cipher.iv = system_password_encryption_iv_ascii

		# generate the ascii-8bit encrypted password
		user_encrypted_password_ascii = cipher.update(password) + cipher.final
		
		# convert the ascii-8bit encrypted password to utf-8 string to store in database
		user_encrypted_password_utf = convert_ascii8bit_to_utf8(user_encrypted_password_ascii)
		
		# save encrypted password in user model 
		user.system_encrypted_password = user_encrypted_password_utf
		user.save
		
	end
		
	# Get unencrypted user password saved encrypted password with encryption key and iv	
	def get_user_password_from_encrypted_password user
		require 'openssl'
		require 'digest/sha1'
		
		# get utf-8 encrypted password from database
		user_encrypted_password_utf = user.system_encrypted_password
		user_password_encryption_key_utf = user.system_password_encryption_key
		user_password_encryption_iv_utf = user.system_password_encryption_iv
		
		# convert utf-8 password and keys to ascii-8bit
		user_encrypted_password_ascii = convert_utf8_to_ascii8bit(user_encrypted_password_utf)
		user_password_encryption_key_ascii = convert_utf8_to_ascii8bit(user_password_encryption_key_utf)
		user_password_encryption_iv_ascii = convert_utf8_to_ascii8bit(user_password_encryption_iv_utf)
		
		# now we create a sipher for decrypting
		decipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
		decipher.decrypt
		
		decipher.key = user_password_encryption_key_ascii
		decipher.iv = user_password_encryption_iv_ascii

		# and decrypt the ascii-8bit encrypted password
		decrypted_password = decipher.update(user_encrypted_password_ascii) + decipher.final
		
		return decrypted_password

	end
		
	# For AM PM Time
	def get_am_pm_time time
		return time.strftime("%I:%M %p") 
	end
	
	# For Month Date Format
	def get_month_date_year time
		return time.strftime("%e %b %y") 
	end
	
	# convert timestamps to human readble time
	def show_human_time time
		current_time = Time.now
		diff_in_sec = current_time - time
		ago = ""
		
		if(diff_in_sec < 60 )
			ago = "Few seconds ago"	
		else
			if(diff_in_sec < 60*60)
				ago = "#{(diff_in_sec/60).to_i} minutes ago"
			else
				if(diff_in_sec < 60*60*24)
					hour_ago = (diff_in_sec/(60*60)).to_i
					min_ago = ((diff_in_sec%(60*60))/60).to_i
					ago = "#{pluralize(hour_ago, "hour")}, #{pluralize(min_ago, "minute")} ago"  
				else
					if(diff_in_sec < 60*60*24*30)
						day_ago = (diff_in_sec/(60*60*24)).to_i
						hour_ago = ((diff_in_sec%(60*60*24))/(60*60)).to_i
						min_ago = (((diff_in_sec%(60*60*24))%(60*60))/60).to_i
						if(day_ago == 1)
							ago = "#{pluralize(hour_ago, "hour")}, #{pluralize(min_ago, "minute")} ago"	
						else	
							ago = "#{pluralize(day_ago, "day")}, #{pluralize(hour_ago, "hour")} ago"		
						end
						
					else
						if(diff_in_sec < 60*60*24*30*12)
							month_ago = (diff_in_sec/(60*60*24*30)).to_i
							day_ago = ((diff_in_sec%(60*60*24*30))/(60*60*24)).to_i
							hour_ago = (((diff_in_sec%(60*60*24*30))%(60*60*24))/(60*60)).to_i
							ago = "#{pluralize(month_ago, "month")}, #{pluralize(day_ago, "day")} ago"
						else
							year_ago = (diff_in_sec/(60*60*24*30*12)).to_i
							month_ago = ((diff_in_sec%(60*60*24*30*12))/(60*60*24*30)).to_i
							day_ago = (((diff_in_sec%(60*60*24*30*12))%(60*60*24*30))/(60*60*24)).to_i
							ago = "#{pluralize(year_ago, "year")}, #{pluralize(month_ago, "month")} ago"
						end
					end
				end
			end	
		end
				
		return ago
	end
		
	def pluralize no, word
		if(no>1)
			word = word + "s"
		end
		return "#{no} #{word}"
	end	

	def is_valid_email email
		(email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/) ? true : false
	end
	
## -------- Private  Methods used in this file Start Here --------- ##			
	
	private
	def convert_utf8_to_ascii8bit utf_string
		return Base64.decode64(utf_string).encode('ascii-8bit') 
	end
	
	private
	def	convert_ascii8bit_to_utf8 ascii_string
		return Base64.encode64(ascii_string).encode('utf-8')
	end

## -------- Private  Methods used in this file Start Here --------- ##				
	
end
