class AddIsAdminToConversationParticipant < ActiveRecord::Migration[5.0]
  def change
  	add_column :conversations, :is_open_group, :boolean, default: false
  	add_column :conversation_participants, :is_admin, :boolean, default: false
  end
end
