class Location < ApplicationRecord

	reverse_geocoded_by :latitude, :longitude
		
	# auto-fetch address
	after_validation :reverse_geocode

	belongs_to :locatable, polymorphic: true

end
