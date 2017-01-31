class AddCustomGradeName < ActiveRecord::Migration[5.0]
  def change
  	add_column :institute_grades, :custom_grade_name, :string, default: ""
  end
end
