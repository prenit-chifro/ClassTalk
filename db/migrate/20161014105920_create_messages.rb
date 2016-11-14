class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
		t.text :content
		t.integer :creator_id
		t.integer :conversation_id
		t.string :seen_user_ids, default: ""
		t.boolean :is_seen_by_all_participants, default: false
		t.string :category, default: "Messages"
		t.timestamps
    end

    add_index :messages, :creator_id
    add_index :messages, :conversation_id
    add_index :messages, :seen_user_ids
    add_index :messages, :category
  end
end
