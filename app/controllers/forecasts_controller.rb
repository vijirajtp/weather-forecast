class ForecastsController < ApplicationController

  # GET /forecasts
  def show
    address = params[:address]

    ## Validates the address
    if address.blank?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Address shouldn't be blank." }
        format.json { render json: { error: "Address shouldn't be blank" }, status: :bad_request }
      end
      return
    end

    ## Service methods to parse and fetch the weather result
    ## Used openweathermap.org to fetch the data
    service = ForecastService.new(address: address.to_s)
    result = service.call

    ## Check whether any error returns from the api
    if result[:error]
      respond_to do |format|
        format.html { redirect_to root_path, alert: result[:error] }
        format.json { render json: { error: result[:error] }, status: :bad_request }
      end
      return
    end

    @forecast = result[:payload]

    respond_to do |format|
      format.html { render :show, notice: "Weather fetched succesfully." }
      format.json { render json: @forecast }
    end
  end

  # GET /forecasts/new
  def new
  end

end
