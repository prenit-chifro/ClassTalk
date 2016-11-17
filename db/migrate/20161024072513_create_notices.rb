class CreateNotices < ActiveRecord::Migration[5.0]
  def change
    create_table :notices do |t|
    	t.string :title
    	t.string :description
    	t.integer :creator_id
    	t.integer :institute_id
    	t.string :grade_section_ids
    	t.string :recipient_ids
        t.string :seen_user_ids, default: ""
        t.boolean :is_seen_by_all_recipients, default: false
      	t.timestamps
    end

    add_index :notices, :creator_id
    add_index :notices, :institute_id
    add_index :notices, :grade_section_ids
    add_index :notices, :recipient_ids
    add_index :notices, :seen_user_ids
  end
end
