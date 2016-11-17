class CreateSubjects < ActiveRecord::Migration[5.0]
  def change
    create_table :subjects do |t|
		t.string :subject_name
		t.timestamps
    end

    add_index :subjects, :subject_name 
  end
end
