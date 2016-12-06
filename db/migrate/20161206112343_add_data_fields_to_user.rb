class AddDataFieldsToUser < ActiveRecord::Migration[5.0]
  def change
  	 add_column :users, :roll_no, :string, default: ""
  	 add_column :users, :staff_id, :string, default: ""
  	 add_column :users, :date_of_birth, :datetime
  	 add_column :users, :address, :string, default: ""
  	 add_column :users, :pincode, :integer
  	 add_column :users, :is_using_transport, :boolean, default: false

  	 add_index :users, :roll_no
     add_index :users, :staff_id
     add_index :users, :address
  end
end
