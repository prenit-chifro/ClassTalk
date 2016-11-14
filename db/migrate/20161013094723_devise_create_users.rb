class DeviseCreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email
	    t.string :mobile_no
	    t.string :isd_code
      t.string :encrypted_password

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at
		
	  # O-auth functionality
	    t.string :oauth_provider
      t.string :oauth_uid

	  # Extra user data
	  t.boolean :email_verified, default: false
	  t.boolean :mobile_no_verified, default: false
	  t.string :first_name
	  t.string :last_name
	  t.string :gender
	  t.string :role
	  t.string :system_encrypted_password
	  t.string :system_password_encryption_key
	  t.string :system_password_encryption_iv
	  t.string :send_account_password_on_android_device_flag, default: false
	  t.string :unique_user_code
	  t.boolean :is_online, default: false
    t.boolean :is_registration_complete, default: false
	  
    t.timestamps null: false
  end

    add_index :users, :email
  	add_index :users, :mobile_no
  	add_index :users, :reset_password_token

    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :role
    add_index :users, :is_registration_complete
      
  end
end
