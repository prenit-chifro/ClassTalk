class CreateAndroidDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :android_devices do |t|
    	t.string   "gcm_registration_id"
		t.integer  "android_device_user_id"
	    t.boolean  "is_android_device_user_signed_in", default: false
      	t.timestamps
    end

    add_index :android_devices, :gcm_registration_id
    add_index :android_devices, :android_device_user_id
  end
end
