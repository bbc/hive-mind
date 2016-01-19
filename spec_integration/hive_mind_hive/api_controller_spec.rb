require 'rails_helper'

RSpec.describe HiveMindHive::ApiController, type: :controller do
  let(:hive_plugin) { HiveMindHive::Plugin.create }
  let(:hive) { Device.create(plugin: hive_plugin) }
  let(:hive_plugin2) { HiveMindHive::Plugin.create }
  let(:hive2) { Device.create(plugin: hive_plugin2) }
  let(:device) { Device.create }
  let(:non_hive) { Device.create }

  describe '#connect' do
    it 'connects a device to a hive' do
      expect {
        put :connect, { connection: { hive_id: hive.id, device_id: device.id } }
      }.to change(Relationship, :count).by 1
      expect(Relationship.last.primary).to eq hive
      expect(Relationship.last.secondary).to eq device
      expect(Relationship.last.relation).to eq 'connected'
      expect(response.status).to eq 200
    end

    it 'does not connect to a device that is not a hive' do
      expect {
        put :connect, { connection: { hive_id: non_hive.id, device_id: device.id } }
      }.to change(Relationship, :count).by 0
      expect(response.status).to eq 422
    end
  end

  describe '#disconnect' do
    it 'disconnects a device from a hive' do
      hive.plugin.connect(device)
      expect {
        put :disconnect, { connection: { hive_id: hive.id, device_id: device.id } }
      }.to change(Relationship, :count).by -1
      expect(response.status).to eq 200
    end

    it 'does not disconnect a device when the wrong hive is given' do
      hive.plugin.connect(device)
      expect {
        put :disconnect, { connection: { hive_id: hive2.id, device_id: device.id } }
      }.to change(Relationship, :count).by 0
      expect(response.status).to eq 422
    end

    it 'does not disconnect from a device that is not a hive' do
      hive.plugin.connect(device)
      expect {
        put :disconnect, { connection: { hive_id: non_hive.id, device_id: device.id } }
      }.to change(Relationship, :count).by 0
      expect(response.status).to eq 422
    end
  end
end
