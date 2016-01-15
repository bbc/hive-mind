module HiveMindHive
  class ApiController < ApplicationController
    def connect
      response = {}
      status = :ok
      hive = Device.find(params[:connection][:hive_id])
      if hive.plugin.is_a? HiveMindHive::Plugin
        device = Device.find(params[:connection][:device_id])

        hive.plugin.connect(device)
      else
        response[:error] = 'Primary device is not a hive'
        status = :unprocessable_entity
      end

      render json: response, status: status
    end

    def disconnect
      response = {}
      status = :ok
      hive = Device.find(params[:connection][:hive_id])
      if hive.plugin.is_a? HiveMindHive::Plugin
        device = Device.find(params[:connection][:device_id])

        if hive == Plugin.find_by_connected_device(device)
          hive.plugin.disconnect(device)
        else
          response[:error] = 'Device not connected to Hive'
          status = :unprocessable_entity
        end
      else
        response[:error] = 'Primary device is not a hive'
        status = :unprocessable_entity
      end

      render json: response, status: status
    end
  end
end
