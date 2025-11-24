require 'httparty'
module WeatherProvider
	# Adapter for OpenWeather 'weather' API
	class OpenWeatherAdapter < Base
		include HTTParty
		base_uri 'https://api.openweathermap.org'

		def initialize(api_key: Rails.application.credentials.openweather_api_key)
			@api_key = api_key
		end


		# Returns a Hash with keys: :temperature_c, :temperature_f, :high_c, :low_c, :description, :fetched_at, :provider
		def current_forecast_for(latitude:, longitude:, postal_code: nil)
			# Using the weather API for consolidated data.
			response = self.class.get('/data/2.5/weather', query: {
				lat: latitude,
				lon: longitude,
				appid: @api_key
			})

			unless response.success?
				raise "weather_provider_error: #{response.code} #{response.message}"
			end

			data = response.parsed_response
			current = data['main'] || {}

			temp_c = safe_fetch_numeric(current['temp'])
			high_c = current['temp_max']
			low_c = current['temp_min']

			{
				temperature_c: temp_c,
				temperature_f: temp_c ? (temp_c.to_f * 9.0 / 5.0 + 32.0).round(2) : 0,
				high_c: high_c,
				low_c: low_c,
				description: data.dig('weather', 0, 'description'),
				fetched_at: Time.current.iso8601,
				provider: 'open_weather'
			}
		end

		private

		def safe_fetch_numeric(value)
			return nil if value.nil?
			Float(value) rescue nil
		end
	end
end