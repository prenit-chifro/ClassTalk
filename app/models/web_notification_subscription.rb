class WebNotificationSubscription < ApplicationRecord
	
	belongs_to :subscriber, class_name: :User, foreign_key: :user_id, inverse_of: :web_notification_subscriptions
	
end
