# This service manages address parsing, geocoding, provider call, and cache management.
class ForecastService
	CACHE_TTL = 30.minutes.freeze

	def initialize(address:, provider: WeatherProvider::OpenWeatherAdapter.new)
		@address = address
		@provider = provider
	end

	def call
		postal_code = AddressParser.new(@address).postal_code!
		cache_key = cache_key_for(postal_code)

		# Read from cache
		cached_payload = Rails.cache.read(cache_key)
		if cached_payload
			# Return cached payload but also mark it as cached
			return { payload: cached_payload.merge(cached: true), cached: true }
		end

		# Not cached: geocode to obtain lat/lon
		location = geocode_first_result

		forecast = @provider.current_forecast_for(latitude: location[:lat], longitude: location[:lng], postal_code: postal_code)

		payload = forecast.merge(postal_code: postal_code, cached: false)

		Rails.cache.write(cache_key, payload, expires_in: CACHE_TTL)

		{ payload: payload, cached: false }
	rescue AddressParser::ParseError => e
		{ error: e.message }
	rescue => e
		Rails.logger.error("ForecastService#call error: #{e.class} #{e.message}\n#{e.backtrace.first(8).join("\n")}")
		{ error: e }
	end

private

	def cache_key_for(postal_code)
		"forecast_zip:#{postal_code}".downcase
	end

	# Use Geocoder search (first result) to get lat/lng. Raise if not found.
	def geocode_first_result
		result = Geocoder.search(@address).first
		raise 'geocode_failed' unless result

		{ lat: result.latitude, lng: result.longitude }
	end
end