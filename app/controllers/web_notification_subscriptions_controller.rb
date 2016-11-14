class WebNotificationSubscriptionsController < ApplicationController
	def create
 		user_id = params[:user_id]
		endpoint = params[:endpoint]
		auth = params[:auth]
		p256dh = params[:p256dh]
		
		old_subscriptions = WebNotificationSubscription.where(user_id: user_id, endpoint: endpoint, auth: auth, p256dh: p256dh)
		if(old_subscriptions.blank?)
			Rails.logger.debug "======================= creating new subscription with params ==================="
			new_subscription = WebNotificationSubscription.new(user_id: user_id, endpoint: endpoint, auth: auth, p256dh: p256dh)
			new_subscription.save
		else
			Rails.logger.debug "======================= old subscription present with same params ==================="
		end
		
		render json: {status: "success"}.to_json
	end
end
