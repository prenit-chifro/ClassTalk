if(current_user.role == "Institute Admin")
	if(!@class_timetable_slots.blank?)
		json.array! @class_timetable_slots do |timetable_slot|
			date_format = '%H:%M'
			subject = timetable_slot.subject

			json.id timetable_slot.id
			json.title subject.subject_name if !subject.blank?
			json.start timetable_slot.start_time.strftime(date_format)
			json.end timetable_slot.end_time.strftime(date_format)
			json.dow [timetable_slot.start_time.wday]
			json.allDay false

			json.url institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Others, format: :js)
			json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch, slot_for: :Others, format: :js)
			json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Others, format: :js)

		end
	end
	if(!@teacher_timetable_slots.blank?)
		json.array! @teacher_timetable_slots do |timetable_slot|
			date_format = '%H:%M'
			grade = timetable_slot.grade
			section = timetable_slot.section
			subject = timetable_slot.subject

			json.id timetable_slot.id
			json.title grade.grade_name + section.section_name if !grade.blank? and !section.blank?
			json.start timetable_slot.start_time.strftime(date_format)
			json.end timetable_slot.end_time.strftime(date_format)
			json.dow [timetable_slot.start_time.wday]
			json.allDay false

			json.url institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Teacher, format: :js)
			json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch, slot_for: :Teacher, format: :js)
			json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Teacher, format: :js)

		end
	end
end

if(current_user.role == "Teacher")
	if(!@teacher_timetable_slots.blank?)
		json.array! @teacher_timetable_slots do |timetable_slot|
			date_format = '%H:%M'
			grade = timetable_slot.grade
			section = timetable_slot.section
			subject = timetable_slot.subject

			json.id timetable_slot.id
			json.title grade.grade_name + section.section_name if !grade.blank? and !section.blank?
			json.start timetable_slot.start_time.strftime(date_format)
			json.end timetable_slot.end_time.strftime(date_format)
			json.dow [timetable_slot.start_time.wday]
			json.allDay false

			json.url institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Teacher, format: :js)
			json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch, slot_for: :Teacher, format: :js)
			json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Teacher, format: :js)

		end
	end
end

if(current_user.role == "Parent" or current_user.role == "Student")
	if(!@class_timetable_slots.blank?)
		json.array! @class_timetable_slots do |timetable_slot|
			date_format = '%H:%M'
			subject = timetable_slot.subject

			json.id timetable_slot.id
			json.title subject.subject_name if !subject.blank?
			json.start timetable_slot.start_time.strftime(date_format)
			json.end timetable_slot.end_time.strftime(date_format)
			json.dow [timetable_slot.start_time.wday]
			json.allDay false

			json.url institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Others, format: :js)
			json.update_url institute_timetable_slot_path(@institute, timetable_slot, method: :patch, slot_for: :Others, format: :js)
			json.edit_url edit_institute_timetable_slot_path(@institute, timetable_slot, slot_for: :Others, format: :js)

		end
	end
end