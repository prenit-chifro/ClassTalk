class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations do |t|
		t.string :conversation_name, default: ""
		t.integer :creator_id
		t.integer :institute_id
		t.integer :grade_id
		t.integer :section_id
        t.integer :subject_id
		t.string :message_categories, default: ""
		t.integer :last_message_id
		t.boolean :is_custom_group, default: true
		t.string :requestor_ids, default: ""
		t.string :blocked_ids, default: ""
		t.timestamps
    end

    add_index :conversations, :conversation_name
    add_index :conversations, :creator_id
    add_index :conversations, :institute_id
    add_index :conversations, :grade_id
    add_index :conversations, :section_id
    add_index :conversations, :subject_id
    add_index :conversations, :message_categories
    add_index :conversations, :last_message_id
    add_index :conversations, :requestor_ids
    add_index :conversations, :blocked_ids
  end
end
