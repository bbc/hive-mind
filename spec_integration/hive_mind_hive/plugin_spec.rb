require 'rails_helper'

RSpec.describe Device, type: :model do
  let(:hive_plugin) { HiveMindHive::Plugin.create }
  let(:hive) { Device.create(plugin: hive_plugin) }
  let(:hive_plugin2) { HiveMindHive::Plugin.create }
  let(:hive2) { Device.create(plugin: hive_plugin2) }
  let(:device1) { Device.create }
  let(:device2) { Device.create }
  let(:device3) { Device.create }

  describe '#connect' do
    it 'connects a device to the hive' do
      expect{
        hive.plugin.connect(device1)
      }.to change(Relationship, :count).by 1
    end

    it 'does not reconnect a device to a hive' do
      hive.plugin.connect(device1)
      expect{
        hive.plugin.connect(device1)
      }.to change(Relationship, :count).by 0
    end

    it 'removes a device from one hive when connecting to another' do
      hive.plugin.connect(device1)
      hive2.plugin.connect(device1)
      expect(hive.plugin.connected_devices).to eq([])
      expect(hive2.plugin.connected_devices).to eq([device1])
    end
  end

  describe '#disconnect' do
    it 'removes a device from a hive' do
      hive.plugin.connect(device1)
      expect{
        hive.plugin.disconnect(device1)
      }.to change(Relationship, :count).by -1
    end

    it 'does not remove a device that is connected to a different hive' do
      hive.plugin.connect(device1)
      expect{
        hive2.plugin.disconnect(device1)
      }.to change(Relationship, :count).by 0
    end
  end

  describe '#connected_devices' do
    it 'returns an empty array for not connected devices' do
      expect(hive.plugin.connected_devices).to eq([])
    end

    it 'lists a single device connected to the hive' do
      hive.plugin.connect(device1)
      expect(hive.plugin.connected_devices).to eq([device1])
    end

    it 'lists three devices connected to the hive' do
      hive.plugin.connect(device1)
      hive.plugin.connect(device2)
      hive.plugin.connect(device3)
      expect(hive.plugin.connected_devices).to match_array([device1, device2, device3])
    end
  end

  describe '#find_by_connected_device' do
    before(:each) do
      hive.plugin.connect(device1)
    end

    it 'returns the hive that a device is connected to' do
      expect(HiveMindHive::Plugin.find_by_connected_device(device1)).to eq hive
    end
  end
end
