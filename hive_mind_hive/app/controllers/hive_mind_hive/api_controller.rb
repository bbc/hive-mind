module HiveMindHive
  class ApiController < ApplicationController
    # This turns off CSRF verification for the API
    # TODO Provide other methods of authentication
    skip_before_action :verify_authenticity_token

    def connect
      response = {}
      status = :ok
      if ! params[:connection][:hive_id]
        response[:error] = 'Missing hive id'
        status = :unprocessable_entity
      elsif ! params[:connection][:device_id]
        response[:error] = 'Missing device id'
        status = :unprocessable_entity
      else
        hive = Device.find(params[:connection][:hive_id])
        if hive.plugin.is_a? HiveMindHive::Plugin
          device = Device.find(params[:connection][:device_id])

          hive.plugin.connect(device)
        else
          response[:error] = 'Primary device is not a hive'
          status = :unprocessable_entity
        end
      end

      render json: response, status: status
    end

    def disconnect
      response = {}
      status = :ok
      if ! params[:connection][:hive_id]
        response[:error] = 'Missing hive id'
        status = :unprocessable_entity
      elsif ! params[:connection][:device_id]
        response[:error] = 'Missing device id'
        status = :unprocessable_entity
      else
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
      end

      render json: response, status: status
    end
  end
end
