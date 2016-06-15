require 'rails_helper'
require 'timecop'

RSpec.describe Api::DeviceStatisticsController, type: :controller do
  let(:valid_session) { {} }

  describe 'POST #upload' do
    let(:device) { Device.create }
    let(:device2) { Device.create }
    let(:device3) { Device.create }

    let(:single_data_point) {
      {
        data: [
                {
                  device_id: device.id,
                  timestamp: '2016-06-07 16:59:01 +0100',
                  label: 'Test key',
                  value: 987.654,
                  format: 'float'
                }
              ]
      }
    }
    let(:five_data_points) {
      {
        data: [
                {
                  device_id: device.id,
                  timestamp: '2016-06-07 16:59:37 +0100',
                  label: 'Test key',
                  value: 987.654,
                  format: 'float'
                },
                {
                  device_id: device2.id,
                  timestamp: '2016-06-07 16:43:59 +0100',
                  label: 'Test key 2',
                  value: 66,
                  format: 'integer'
                },
                {
                  device_id: device.id,
                  timestamp: '2016-06-07 16:59:01 +0100',
                  label: 'Test key 3',
                  value: -5.2,
                  format: 'float'
                },
                {
                  device_id: device3.id,
                  timestamp: '2016-06-07 17:59:01 +0100',
                  label: 'Test key',
                  value: 11.22,
                  format: 'float'
                },
                {
                  device_id: device3.id,
                  timestamp: '2016-06-07 18:37:44 +0100',
                  label: 'Test key 3',
                  value: 0.0,
                  format: 'float'
                }
              ]
      }
    }

    it 'adds a new statistics datum' do
      expect {
        post :upload, single_data_point, valid_session
      }.to change(DeviceStatistic, :count).by 1
      stat = DeviceStatistic.last
      expect(stat.device).to eq device
      expect(stat.timestamp).to eq '2016-06-07 16:59:01 +0100'
      expect(stat.label).to eq 'Test key'
      expect(stat.value).to eq 987.654
      expect(stat.format).to eq 'float'
    end

    it 'adds multiple data points' do
      expect {
        post :upload, five_data_points, valid_session
      }.to change(DeviceStatistic, :count).by 5
    end
  end
end
