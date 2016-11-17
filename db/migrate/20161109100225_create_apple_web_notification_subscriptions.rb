class CreateAppleWebNotificationSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :apple_web_notification_subscriptions do |t|
    	t.string :device_token
    	t.integer :user_id
      	t.timestamps
    end

    add_index :apple_web_notification_subscriptions, :device_token
    add_index :apple_web_notification_subscriptions, :user_id
  end
end
