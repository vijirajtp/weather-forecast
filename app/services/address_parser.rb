# Uses Geocoder to convert free text address into a postal code.
class AddressParser
	class ParseError < StandardError; end

	def initialize(address)
		@address = address.to_s
	end

	# Returns postal code string or raises AddressParser::ParseError
	def postal_code!
		results = Geocoder.search(@address)
		raise ParseError, 'address_not_found' if results.empty?

		location = results.first
		postal_code = location.postal_code || location.data.dig('address', 'postcode')

		raise ParseError, 'postal_code_not_found' unless postal_code.present?

		postal_code.to_s.strip
	end
end