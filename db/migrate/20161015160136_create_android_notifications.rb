class CreateAndroidNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :android_notifications do |t|
    	t.string   "title"
	    t.string   "message"
	    t.string   "target_url"
	    t.string   "image_url"
	    t.text     "big_image_url", limit: 65535
	    t.timestamps
    end

  end
end
