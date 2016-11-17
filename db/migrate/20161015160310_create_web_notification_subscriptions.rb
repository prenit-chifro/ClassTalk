class CreateWebNotificationSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :web_notification_subscriptions do |t|
    	t.integer  "user_id"
	    t.text     "endpoint",   limit: 65535
	    t.string   "auth"
	    t.string   "p256dh"
      	t.timestamps
    end

    add_index :web_notification_subscriptions, :user_id
    add_index :web_notification_subscriptions, :auth
    add_index :web_notification_subscriptions, :p256dh
  end
end
