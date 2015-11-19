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
  end
end
