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

  # GET /stat
  def get_stats
    data = Device
      .find(params[:device_id])
      .device_statistics
      .where(label: params[:key])
      .order(:timestamp)
      .last(params[:npoints].to_i)
      .map{ |ds| ds.value }

    render json: {
        data: data
      }, status: :ok
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
