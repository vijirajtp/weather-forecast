module WeatherProvider
	# Base interface for weather provider adapters. Adapters must
	# implement #current_forecast_for(latitude:, longitude:, postal_code:)
	class Base
		def current_forecast_for(latitude:, longitude:, postal_code: nil)
			raise NotImplementedError, 'Adapters must implement #current_forecast_for'
		end
	end
end