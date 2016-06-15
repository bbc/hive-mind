class Api::DeviceStatisticsController < ApplicationController
  # This turns off CSRF verification for the API
  # TODO Provide other methods of authentication
  skip_before_action :verify_authenticity_token

  # POST /upload
  def upload
    params[:data].each do |datum|
      DeviceStatistic.create(upload_params(datum))
    end
    render json: {}, status: :ok
  end

  private
  def upload_params(datum)
    datum.permit(
      :device_id,
      :timestamp,
      :label,
      :value,
      :format
    )
  end
end
