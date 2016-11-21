date_format = '%H:%M'

json.id timetable_slot.id
json.start timetable_slot.start_time.strftime(date_format)
json.end timetable_slot.end_time.strftime(date_format)
json.dow [timetable_slot.start_time.wday]
json.allDay false

json.url institute_timetable_slot_path(@institute, timetable_slot, format: :js)
json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch, format: :js)
json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot, format: :js)

if(slot_for == :Teacher)
	grade = timetable_slot.grade
	section = timetable_slot.section
	json.title grade.grade_name + section.section_name if !grade.blank? and !section.blank?
else
	subject = timetable_slot.subject
	json.title subject.subject_name if !subject.blank?
end
