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

  describe 'GET #get_stats' do
    let(:device) { Device.create }
    let(:device2) { Device.create }

    it 'returns the correct number of data points' do
      5.times do |i|
        DeviceStatistic.create(
          device: device,
          label: 'Test stat',
          value: 1
        )
      end
      get :get_stats, { device_id: device.id, key: 'Test stat', npoints: 5 }, valid_session
      expect(JSON.parse(response.body)['data'].length).to eq 5
    end

    it 'does not return too many data points' do
      5.times do |i|
        DeviceStatistic.create(
          device: device,
          label: 'Test stat',
          value: 1
        )
      end
      get :get_stats, { device_id: device.id, key: 'Test stat', npoints: 3 }, valid_session
      expect(JSON.parse(response.body)['data'].length).to eq 3
    end

    it 'does not return data points ordered by timestamp' do
      DeviceStatistic.create(timestamp: '2016-06-29 10:14:53 +0100', value: 1, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:17:53 +0100', value: 2, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:15:53 +0100', value: 3, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:18:53 +0100', value: 4, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:16:53 +0100', value: 5, format: 'integer', device: device, label: 'Test stat')
      get :get_stats, { device_id: device.id, key: 'Test stat', npoints: 3 }, valid_session
      expect(JSON.parse(response.body)['data']).to eq [ 5, 2, 4 ]
    end

    it 'gets all datapoints when fewer than requested are available' do
      5.times do |i|
        DeviceStatistic.create(
          device: device,
          label: 'Test stat',
          value: 1
        )
      end
      get :get_stats, { device_id: device.id, key: 'Test stat', npoints: 8 }, valid_session
      expect(JSON.parse(response.body)['data'].length).to eq 5
    end

    it 'returns an empty array for no data' do
      get :get_stats, { device_id: device.id, key: 'Unknown stat', npoints: 5 }, valid_session
      expect(JSON.parse(response.body)['data']).to be_an Array
      expect(JSON.parse(response.body)['data'].length).to eq 0
    end

    it 'returns data for the correct device' do
      DeviceStatistic.create(timestamp: '2016-06-29 10:14:53 +0100', value: 11, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:17:53 +0100', value: 12, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:15:53 +0100', value: 13, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:18:53 +0100', value: 14, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:16:53 +0100', value: 15, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:14:53 +0100', value: 21, format: 'integer', device: device2, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 11:17:53 +0100', value: 22, format: 'integer', device: device2, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:15:53 +0100', value: 23, format: 'integer', device: device2, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 09:18:53 +0100', value: 24, format: 'integer', device: device2, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:16:53 +0100', value: 25, format: 'integer', device: device2, label: 'Test stat')
      get :get_stats, { device_id: device.id, key: 'Test stat', npoints: 3 }, valid_session
      expect(JSON.parse(response.body)['data']).to eq [ 15, 12, 14 ]
    end

    it 'returns data for the correct statistic' do
      DeviceStatistic.create(timestamp: '2016-06-29 10:14:53 +0100', value: 11, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:17:53 +0100', value: 12, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:15:53 +0100', value: 13, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:18:53 +0100', value: 14, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:16:53 +0100', value: 15, format: 'integer', device: device, label: 'Test stat')
      DeviceStatistic.create(timestamp: '2016-06-29 10:14:53 +0100', value: 21, format: 'integer', device: device, label: 'Test stat 2')
      DeviceStatistic.create(timestamp: '2016-06-29 11:17:53 +0100', value: 22, format: 'integer', device: device, label: 'Test stat 2')
      DeviceStatistic.create(timestamp: '2016-06-29 10:15:53 +0100', value: 23, format: 'integer', device: device, label: 'Test stat 2')
      DeviceStatistic.create(timestamp: '2016-06-29 09:18:53 +0100', value: 24, format: 'integer', device: device, label: 'Test stat 2')
      DeviceStatistic.create(timestamp: '2016-06-29 10:16:53 +0100', value: 25, format: 'integer', device: device, label: 'Test stat 2')
      get :get_stats, { device_id: device.id, key: 'Test stat', npoints: 3 }, valid_session
      expect(JSON.parse(response.body)['data']).to eq [ 15, 12, 14 ]
    end
  end
end
