if(current_user.role == "Institute Admin")
	if(!@class_timetable_slots.blank?)
		json.array! @class_timetable_slots do |timetable_slot|
			date_format = '%H:%M'
			subject = timetable_slot.subject

			json.id timetable_slot.id
			json.title subject.subject_name if !subject.blank?
			json.start timetable_slot.start_time.strftime(date_format)
			json.end timetable_slot.end_time.strftime(date_format)
			json.dow [timetable_slot.start_time.wday+1]
			json.allDay false

			json.url institute_timetable_slot_path(@institute, timetable_slot)
			json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch)
			json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot)

		end
	end
end