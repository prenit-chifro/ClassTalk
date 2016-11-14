class SafariWebPushController < ApplicationController

	skip_before_filter :verify_authenticity_token


  # When a user allows permission to receive push notifications, a POST request is sent to the following URL:
  # webServiceURL/version/pushPackages/websitePushID
  # post '/:version/pushPackages/:website_push_id' => 'safari_apn#package'
  def send_push_package
    
    require 'push_package'

	website_params = {
	  websiteName: "ClassTalk",
	  websitePushID: "web.push.in.classtalk",
	  allowedDomains: ["https://classtalk.in", "http://classtalk.in", "https://www.classtalk.in","http://www.classtalk.in"],
	  urlFormatString: "https://classtalk.in%@",
	  authenticationToken: SecureRandom.base64(12).gsub(/=+$/,''),
	  webServiceURL: "https://classtalk.in"
	}

	iconset_path = File.join(Rails.root, 'public', 'icon.iconset')
	certificate = File.join(Rails.root, 'ssl', 'ClassTalk_web_push_p12_Certificates.p12')
	intermediate_cert = File.join(Rails.root, 'ssl','AppleWWDRCA.cer')
	package = PushPackage.new(website_params, iconset_path, certificate, '', intermediate_cert)

	FileUtils::mkdir_p(File.join(Rails.root, 'public', 'pushPackages', "user_#{params[:user_id]}"))

	package.save(File.join(Rails.root, 'public', 'pushPackages', "user_#{params[:user_id]}", 'pushPackage.zip'))


    #return the push package


    send_file(File.join(Rails.root, 'public', 'pushPackages', "user_#{params[:user_id]}", 'pushPackage.zip'), type: 'application/zip', disposition: 'inline')
  end

  # When users first grant permission, or later change their permission levels for your website, a POST request is sent to the following URL:
  # webServiceURL/version/devices/deviceToken/registrations/websitePushID
  # post '/:version/devices/:device_token/registrations/:website_push_id' => 'safari_apn#register'
  def register_device
    # In the HTTP request is an Authorization header. Its value is the word ApplePushNotifications and the authentication token, separated by a single space. The authentication token is the same token that’s specified in your package’s website.json file. Your web service can use this authentication token to determine which user is removing their permission policy.
    # Use this authentication token to remove the device token from your database, as if the device had never registered to your service.
    
    #TODO: Create a record to store this device token. It will be used to send push notifications later.
    old_subscription = AppleWebNotificationSubscription.find_by(user_id: params[:user_id], device_token: params[:device_token])
    if(old_subscription.blank?)
    	new_subscription = AppleWebNotificationSubscription.create(user_id: params[:user_id], device_token: params[:device_token])
    end
    

    render json: {message: 'ok'}, status: 200
  end

  # If a user removes permission of a website in Safari preferences, a DELETE request is sent to the following URL:
  # webServiceURL/version/devices/deviceToken/registrations/websitePushID
  # delete '/:version/devices/:device_token/registrations/:website_push_id' => 'safari_apn#unregister'
  def unregister_device
    # In the HTTP request is an Authorization header. Its value is the word ApplePushNotifications and the authentication token, separated by a single space. The authentication token is the same token that’s specified in your package’s website.json file. Your web service can use this authentication token to determine which user is removing their permission policy.
    # Use this authentication token to remove the device token from your database, as if the device had never registered to your service.
    
    #TODO: Delete the record with this device token. The device will no longer accept notifications.

    old_subscription = AppleWebNotificationSubscription.find_by(user_id: params[:user_id], device_token: params[:device_token])
    old_subscription.destroy if !old_subscription.blank?

    render json: {message: 'ok'}, status: 200
  end

  # If an error occurs, a POST request is sent to the following URL:
  # webServiceURL/version/log
  # post '/:version/log' => 'safari_apn#log'
  def log
    # In the HTTP body is a JSON dictionary containing a single key, named logs, which holds an array of strings describing the errors that occurred.
    # Use this endpoint to help you debug your web service implementation. The logs contain a description of the error in a human-readable format. See “Troubleshooting” for a list of possible errors.
    
    #TODO: Log the incoming messages intelligently within the application.
    Rails.logger.debug "===================================== error from apple web push notification #{params.inspect} =================================="
    render json: {message: 'ok'}, status: 200
  end

end
