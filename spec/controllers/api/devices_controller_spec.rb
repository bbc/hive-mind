require 'rails_helper'

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
        skip 'Mock broken'
        {
          device_type: :mock,
          name: 'Known device',
          extra_data_one: 'Data one',
          extra_data_two: 2
        }
      }

      let(:device_without_name) {
        skip 'Mock broken'
        {
          device_type: :mock
        }
      }

      let(:device_with_name) {
        skip 'Mock broken'
        {
          device_type: :mock,
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
        expect(Device.last.device_type).to eq 'mock'
      end

      it 'sets the device data id' do
        post :register, {device: known_device_type}, valid_session
        expect(Device.last.device_data_id).to_not be_nil
      end

      it 'passes through attributes' do
        post :register, {device: known_device_type}, valid_session
        expect(HiveMindMock.data_set[0]).to be_truthy
        expect(HiveMindMock.data_set[1]).to be_truthy
        expect(HiveMindMock.data_set[2]).to be_falsy
      end

      it 'generates a name from engine' do
        post :register, {device: device_without_name}, valid_session
        expect(Device.last.name).to eq 'Mock device name'
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
  end
end
