class CreateGrades < ActiveRecord::Migration[5.0]
  def change
    create_table :grades do |t|
		t.string :grade_name
		t.timestamps
    end

    add_index :grades, :grade_name 
  end
end
