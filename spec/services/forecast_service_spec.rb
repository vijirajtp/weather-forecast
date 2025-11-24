# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ForecastService, type: :service do
  # Common test data
  let(:address) { '620 Herndon Parkway, Herndon, VA 20170-4826' }
  let(:postal_code) { '94043' }
  let(:cache_key) { "forecast_zip:#{postal_code}" }
  let(:geocode_result) { OpenStruct.new(latitude: 38.969, longitude: -77.385) }
  let(:provider_double) { instance_double(WeatherProvider::OpenWeatherAdapter) }

  before do
    # Ensure cache is clean at start of each test
    Rails.cache.clear

    parser = instance_double(AddressParser)
    allow(AddressParser).to receive(:new).with(address).and_return(parser)
    allow(parser).to receive(:postal_code!).and_return(postal_code)
    allow(Geocoder).to receive(:search).with(address).and_return([geocode_result])
  end

  describe 'cache hit' do
    it 'returns cached payload and does not call provider' do
      # write a payload into the cache to simulate a cache hit
      cached_payload = {
        temperature_c: 12.3,
        temperature_f: 54.14,
        high_c: 14.0,
        low_c: 8.0,
        description: 'partly cloudy',
        fetched_at: Time.current.iso8601,
        provider: 'open_weather',
        postal_code: postal_code,
        cached: true
      }
      Rails.cache.write(cache_key, cached_payload, expires_in: 30.minutes)

      service = ForecastService.new(address: address, provider: provider_double)

      # Perform api call
      result = service.call

      # Assert
      expect(result[:cached]).to be true
      expect(result[:payload]).to be_a(Hash)
      expect(result[:payload][:postal_code]).to eq(postal_code)
      expect(result[:payload][:temperature_c]).to eq(12.3)
      expect(provider_double).not_to have_received(:current_forecast_for)
    end
  end
end