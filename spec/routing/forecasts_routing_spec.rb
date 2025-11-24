require "rails_helper"

RSpec.describe ForecastsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/").to route_to("forecasts#new")
    end

    it "routes to #show" do
      expect(get: "/forecast").to route_to("forecasts#show")
    end
  end
end
