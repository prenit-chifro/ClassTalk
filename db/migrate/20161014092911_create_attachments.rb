class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
	  t.string :category
      t.references :attachable, polymorphic: true, index: true
      t.timestamps
    end
	add_attachment :attachments, :media
	add_index :attachments, :category
  end
end
