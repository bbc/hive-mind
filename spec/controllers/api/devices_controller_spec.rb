require 'rails_helper'
require 'timecop'

RSpec.describe Api::DevicesController, type: :controller do
  let(:valid_attributes) {
    {
      name: 'Device 1'
    }
  }

  let(:device_with_mac1) {
    {
      name: 'Device 1',
      macs: [ 'aa:bb:cc:dd:ee:01' ]
    }
  }

  let(:device_with_mac2) {
    {
      name: 'Device 2',
      macs: [ 'aa:bb:cc:dd:ee:02' ]
    }
  }

  let(:valid_session) { {} }

  describe 'POST #register' do
    it 'registers a new device without unique identifier' do
      expect {
        post :register, {device: valid_attributes}, valid_session
      }.to change(Device, :count).by(1)
    end

    it 'does not reregister a known device' do
      device = Device.create! valid_attributes
      expect {
        post :register, {device: valid_attributes.merge(id: device.id)}, valid_session
      }.to change(Device, :count).by(0)
    end

    it 'registers two devices with different MACs' do
      post :register, {device: device_with_mac1}, valid_session
      expect {
        post :register, {device: device_with_mac2}, valid_session
      }.to change(Device, :count).by(1)
    end

    it 'identifies device by MAC' do
      post :register, {device: device_with_mac1}, valid_session
      expect {
        post :register, {device: device_with_mac1}, valid_session
      }.to change(Device, :count).by(0)
    end

    it 'sets the heartbeat' do
      post :register, {device: valid_attributes}, valid_session
      Timecop.freeze(Time.now + 30) do
        expect(Device.last.seconds_since_heartbeat).to eq 30
      end
    end

    context 'unknown device type' do
      let(:unknown_device_type) {
        {
          device_type: :unknown,
          name: 'Unknown device'
        }
      }

      it 'registeres the unknown device' do
        expect {
          post :register, {device: unknown_device_type}, valid_session
        }.to change(Device, :count).by(1)
      end

      it 'sets the device type as nil' do
        post :register, {device: unknown_device_type}, valid_session
        expect(Device.last.plugin_type).to be_nil
      end

      it 'sets the device data id as nil' do
        post :register, {device: unknown_device_type}, valid_session
        expect(Device.last.plugin_id).to be_nil
      end
    end

    context 'known device type' do
      let(:known_device_type) {
        {
          model: :test_model,
          brand: :test_brand,
          device_type: :generic,
          name: 'Known device',
          extra_data_one: 'Data one',
          extra_data_two: 2
        }
      }

      let(:device_without_name) {
        {
          model: :test_model,
          brand: :test_brand,
          device_type: :generic
        }
      }

      let(:device_with_name) {
        {
          model: :test_model,
          brand: :test_brand,
          device_type: :generic,
          name: 'User defined device name'
        }
      }

      it 'registeres the known device' do
        expect {
          post :register, {device: known_device_type}, valid_session
        }.to change(Device, :count).by(1)
      end

      it 'sets the device type' do
        post :register, {device: known_device_type}, valid_session
        expect(Device.last.device_type).to eq 'generic'
      end

      it 'passes through attributes' do
        post :register, {device: known_device_type}, valid_session
        plugin = Device.last.plugin
        expect(plugin.details['extra_data_one']).to eq 'Data one'
        expect(plugin.details['extra_data_two']).to eq '2'
        expect(plugin.details['extra_data_three']).to be_nil
      end

      it 'generates a name from engine' do
        post :register, {device: device_without_name}, valid_session
        expect(Device.last.name).to_not be_nil
      end

      it 'overrides name set by engine' do
        post :register, {device: device_with_name}, valid_session
        expect(Device.last.name).to eq 'User defined device name'
      end
    end

    context 'device models, types and brands' do
      let(:brand1_model1) {
        {
          name: 'Device 1',
          model: 'Model 1',
          brand: 'Brand 1',
        }
      }

      let(:brand1_model2) {
        {
          name: 'Device 2',
          model: 'Model 2',
          brand: 'Brand 1',
        }
      }

      let(:brand2_model1) {
        {
          name: 'Device 3',
          model: 'Model 1',
          brand: 'Brand 2',
        }
      }

      let(:brand2_model2) {
        {
          name: 'Device 4',
          model: 'Model 2',
          brand: 'Brand 2',
        }
      }

      let(:brand1_model1_type1) {
        {
          name: 'Device 5',
          model: 'Model 1',
          brand: 'Brand 1',
          device_type: 'Type 1',
        }
      }

      let(:brand1_model1_type2) {
        {
          name: 'Device 6',
          model: 'Model 1',
          brand: 'Brand 1',
          device_type: 'Type 2',
        }
      }

      it 'creates a new model' do
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Model, :count).by(1)
      end

      it 'creates a new brand' do
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Brand, :count).by(1)
      end

      it 'creates a new model for an existing brand' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model2}, valid_session
        }.to change(Model, :count).by(1)
      end

      it 'creates a new brand with an existing model name' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand2_model1}, valid_session
        }.to change(Brand, :count).by(1)
      end

      it 'it does not recreate a known model' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Model, :count).by(0)
      end

      it 'it does not recreate a known brand for a known model' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Brand, :count).by(0)
      end

      it 'it does not recreate a known brand for a new model' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model2}, valid_session
        }.to change(Brand, :count).by(0)
      end

      it 'creates a new type' do
        expect {
          post :register, {device: brand1_model1_type1}, valid_session
        }.to change(DeviceType, :count).by(1)
      end

      it 'does not recreate an existing type' do
        post :register, {device: brand1_model1_type1}, valid_session
        expect {
          post :register, {device: brand1_model1_type1}, valid_session
        }.to change(DeviceType, :count).by(0)
      end

      it 'creates a new type for an existing model and brand' do
        post :register, {device: brand1_model1_type1}, valid_session
        expect {
          post :register, {device: brand1_model1_type2}, valid_session
        }.to change(DeviceType, :count).by(1)
      end

      it 'creates a new model for an existing model/brand with a new type' do
        post :register, {device: brand1_model1_type1}, valid_session
        expect {
          post :register, {device: brand1_model1_type2}, valid_session
        }.to change(Model, :count).by(1)
      end
    end

    context 'plugin with device identifier method' do
      let(:device) {
        {
          name: 'Device',
          model: 'Model',
          brand: 'Brand',
          device_type: 'Controllermockone',
        }
      }

      module HiveMindControllermockone
        class Plugin < HiveMindGeneric::Plugin
          def self.identify_existing options = {}
            if identifier = HiveMindGeneric::Characteristic.find_by(key: 'id_key', value: options[:id_key])
              identifier.plugin.device
            else
              nil
            end
          end
        end
      end

      it 'identifies device based on plugin identifier method' do
        post :register, {device: device.merge(
                                   id_key: '12468',
                                   macs: ['aa:aa:aa:aa:aa:01']
                                 )}, valid_session
        expect {
          post :register, {device: device.merge(
                                     id_key: '12468',
                                     macs: ['aa:aa:aa:aa:aa:02']
                                   )}, valid_session
        }.to change(Device, :count).by(0)
      end

      it 'creates new device with different unique identifier' do
        post :register, {device: device.merge(
                                   id_key: '12468',
                                   macs: ['aa:aa:aa:aa:aa:01']
                                 )}, valid_session
        expect {
          post :register, {device: device.merge(
                                   id_key: '12469',
                                   macs: ['aa:aa:aa:aa:aa:02']
                                 )}, valid_session
        }.to change(Device, :count).by(1)
        expect {
          post :register, {device: device.merge(
                                   id_key: '12470',
                                   macs: ['aa:aa:aa:aa:aa:01']
                                 )}, valid_session
        }.to change(Device, :count).by(1)
      end
    end
  end

  describe 'PUT #poll' do
    let(:device) { Device.create(name: 'Test device') }
    let(:device2) { Device.create(name: 'Test device 2') }
    let(:device3) { Device.create(name: 'Test device 3') }
    let(:reporting_device) { Device.create(name: 'Reporting device') }

    it 'adds a heartbeat for a known device' do
      expect {
        put :poll, { poll: { id: device.id } }
      }.to change(Heartbeat, :count).by(1)
    end

    it 'sets the heartbeat for the correct device' do
      put :poll, { poll: { id: device.id } }
      expect(Heartbeat.last.device).to eq device
    end

    it 'sets the reporting device for a self reporting device' do
      put :poll, { poll: { id: device.id } }
      expect(Heartbeat.last.reporting_device).to eq device
    end

    it 'sets the device of a hearbeat when reported by a different device' do
      put :poll, { poll: { devices: [ device.id ], id: reporting_device.id } }
      expect(Heartbeat.last.device).to eq device
    end

    it 'sets the reporting device as different from the device' do
      put :poll, { poll: { devices: [ device.id ], id: reporting_device.id } }
      expect(Heartbeat.last.reporting_device).to eq reporting_device
    end

    it 'polls multiple devices' do
      expect {
        put :poll, { poll: { devices: [ device.id, device2.id, device3.id ], id: reporting_device.id } }
      }.to change(Heartbeat, :count).by(3)
      expect(Heartbeat.last(3).map{ |h| h.device }).to match [ device, device2, device3 ]
    end

    it 'fails to set a heartbeat for an unknown device' do
      expect {
        put :poll, { poll: { id: -1 } }
      }.to change(Heartbeat, :count).by(0)
    end

    it 'report an unknown device correctly' do
      put :poll, { poll: { id: -1 } }
      expect(response).to have_http_status(:not_found)
    end

    it 'report an unknown reporting device correctly' do
      put :poll, { poll: { devices: [ device.id ], id: -1 } }
      expect(response).to have_http_status(:not_found)
    end
  end
end
