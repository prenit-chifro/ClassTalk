class CreateSections < ActiveRecord::Migration[5.0]
  def change
    create_table :sections do |t|
		t.string :section_name
		t.timestamps
    end

    add_index :sections, :section_name 
  end
end
