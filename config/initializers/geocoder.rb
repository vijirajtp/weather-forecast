Geocoder.configure(
	# Geocoding options
	timeout: 5,
	lookup: :nominatim, # default; you can configure provider via ENV if desired
	units: :km
)