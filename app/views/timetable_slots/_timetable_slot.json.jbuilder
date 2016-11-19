date_format = '%H:%M %p'

json.id timetable_slot.id
json.title timetable_slot.subject.subject_name
json.start timetable_slot.start_time.strftime(date_format)
json.end timetable_slot.end_time.strftime(date_format)
json.allDay false

json.url institute_timetable_slot_path(@institute, timetable_slot)
json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch)
json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot)

