date_format = event.is_all_day_event ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id event.id
json.title event.title
json.description event.description
json.start event.start_time.strftime(date_format)
json.end event.end_time.strftime(date_format)
json.allDay event.is_all_day_event ? true : false

json.url institute_event_path(@institute, event)
json.update_url institute_event_path(@institute, event, method: :patch)
json.edit_url edit_institute_event_path(@institute, event)

