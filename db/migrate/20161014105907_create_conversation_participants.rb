class CreateConversationParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :conversation_participants do |t|
		t.integer :conversation_id
		t.integer :participant_id
		t.integer :participant_adder_id
		t.timestamps
    end

    add_index :conversation_participants, :conversation_id
    add_index :conversation_participants, :participant_id
    
  end
end
