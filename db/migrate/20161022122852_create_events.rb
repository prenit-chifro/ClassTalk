class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
    	t.string :title
    	t.string :description
    	t.datetime :start_time
    	t.datetime :end_time
    	t.boolean :is_all_day_event
    	t.integer :creator_id
        t.string :participant_ids
        t.boolean :is_official
    	t.integer :institute_id
    	t.string :grade_section_ids
	    t.timestamps
    end

    add_index :events, :start_time
    add_index :events, :end_time
    add_index :events, :creator_id
    add_index :events, :participant_ids
    add_index :events, :institute_id
    add_index :events, :grade_section_ids
  end
end
