json.array! @events do |event|
	date_format = event.is_all_day_event ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

	json.id event.id
	json.title event.title
	json.description event.description
	json.start event.start_time.strftime(date_format)
	json.end event.end_time.strftime(date_format)
	json.allDay event.is_all_day_event ? true : false

	json.url event_path(event)
	json.update_url event_path(event, method: :patch)
	json.edit_url edit_event_path(event)

end
