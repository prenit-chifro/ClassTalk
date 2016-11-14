class CreateIosDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :ios_devices do |t|
    	t.string :ios_device_token
    	t.integer :ios_device_user_id
    	t.boolean :is_ios_device_user_signed_in
	    t.timestamps
    end
  end
end
