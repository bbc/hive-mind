require 'rails_helper'
require 'timecop'

RSpec.describe Device, type: :model do
  describe '#mac_addresses' do
    it 'returns an empty list of mac addresses' do
      dev = Device.new(name: 'Device with no mac address')
      expect(dev.mac_addresses).to eq []
    end

    it 'returns a list of mac addresses' do
      dev = Device.create(
        name: 'Device with no mac address',
        macs: [Mac.create(mac: 'aa:bb:cc:dd:ee:01'), Mac.create(mac: 'aa:bb:cc:dd:ee:02'), Mac.create(mac: 'aa:bb:cc:dd:ee:03')]
      )
      expect(dev.mac_addresses).to match ['aa:bb:cc:dd:ee:01', 'aa:bb:cc:dd:ee:02', 'aa:bb:cc:dd:ee:03']
    end

    it 'returns a list containing a single mac address' do
      dev = Device.new(
        name: 'Device with no mac address',
        macs: [Mac.create(mac: 'aa:bb:cc:dd:ee:01')]
      )
      expect(dev.mac_addresses).to eq ['aa:bb:cc:dd:ee:01']
    end
  end

  describe '#ip_addresses' do
    it 'returns an empty list of ip addresses' do
      dev = Device.new(name: 'Device with no ip address')
      expect(dev.ip_addresses).to eq []
    end

    it 'returns a list of ip addresses' do
      dev = Device.create(
        name: 'Device with no ip address',
        ips: [Ip.create(ip: '10.10.10.1'), Ip.create(ip: '192.168.99.99'), Ip.create(ip: '8.8.8.8')]
      )
      expect(dev.ip_addresses).to match ['10.10.10.1', '192.168.99.99', '8.8.8.8']
    end

    it 'returns a list containing a single ip address' do
      dev = Device.new(
        name: 'Device with no ip address',
        ips: [Ip.create(ip: '10.10.10.1')]
      )
      expect(dev.ip_addresses).to eq ['10.10.10.1']
    end
  end

  describe '#identify_existing' do
    let(:unknown) {
      {
        name: 'Unknown device',
        macs: [ Mac.create(mac: 'ff:ff:ff:ff:ff:ff') ]
      }
    }

    let(:mac1) { Mac.create(mac: 'aa:aa:aa:aa:aa:01') }
    let(:mac2) { Mac.create(mac: 'aa:aa:aa:aa:aa:02') }
    let(:mac3) { Mac.create(mac: 'aa:aa:aa:aa:aa:03') }

    let(:no_plugin) {
      Device.create(
        name: 'Device with no plugin',
        macs: [ mac1 ]
      )
    }

    module HiveMindMockone
      class Plugin < HiveMindGeneric::Plugin
        def self.identify_existing options = {}
          @device
        end

        def self.set_device device
          @device = device
        end
      end
    end
    let(:plugin1) {
      HiveMindMockone::Plugin.create()
    }

    module HiveMindMocktwo
      class Plugin < HiveMindGeneric::Plugin
        def self.identify_existing options = {}
          nil
        end
      end
    end
    let(:plugin2) {
      HiveMindMocktwo::Plugin.create()
    }

    module HiveMindMockthree
      class Plugin < HiveMindGeneric::Plugin
      end
    end
    let(:plugin3) {
      HiveMindMockthree::Plugin.create()
    }

    let(:plugin_with_identifier_method) {
      Device.create(
        name: 'Device with plugin 1',
        macs: [ mac1 ],
        plugin: plugin1
      )
    }

    let(:plugin_with_identifier_method_nil) {
      Device.create(
        name: 'Device with plugin 2',
        macs: [ mac1 ],
        plugin: plugin2
      )
    }

    let(:plugin_without_identifier_method) {
      Device.create(
        name: 'Device with plugin 3',
        macs: [ mac3 ],
        plugin: plugin3
      )
    }

    it 'returns nil for unknown details' do
      expect(Device.identify_existing(unknown)).to be_nil
    end

    it 'finds device of unknown type based on mac' do
      no_plugin.save
      expect(Device.identify_existing(name: 'New name', macs: [ mac1 ])).to eq no_plugin
    end

    it 'uniquely identifies based on plugin' do
      plugin_with_identifier_method.save
      HiveMindMockone::Plugin.set_device(plugin_with_identifier_method)
      expect(Device.identify_existing(name: 'New name', macs: [ mac2 ], device_type: 'mockone')).to eq plugin_with_identifier_method
    end

    it 'returns nil for unknown device based on plugin' do
      plugin_with_identifier_method_nil.save
      expect(Device.identify_existing(name: 'New name', macs: [ mac1 ], device_type: 'mocktwo')).to be_nil
    end

    it 'uniquely identifies based on mac if plugin has no identify_existing method' do
      plugin_without_identifier_method.save
      expect(Device.identify_existing(name: 'New name', macs: [ mac3 ], device_type: 'mockthree')).to eq plugin_without_identifier_method
      expect(Device.identify_existing(name: 'New name', macs: [ mac2 ], device_type: 'mockthree')).to be_nil
    end
  end

  describe '#details' do
    module HiveMindMockwithdetails
      class Plugin < HiveMindGeneric::Plugin
        def details
          {
            'key1' => 'value1',
            'key2' => 'value2',
          }
        end
      end
    end
    let(:plugin1) {
      HiveMindMockwithdetails::Plugin.create()
    }

    let(:device) {
      Device.create(
        name: 'Test device',
        macs: [Mac.create(mac: 'aa:bb:cc:dd:ee:01'), Mac.create(mac: 'aa:bb:cc:dd:ee:02'), Mac.create(mac: 'aa:bb:cc:dd:ee:03')],
        ips: [Ip.create(ip: '10.10.10.1'), Ip.create(ip: '192.168.99.99'), Ip.create(ip: '8.8.8.8')],
        plugin: plugin1
      )
    }

    it 'returns an hash' do
      expect(device.details).to be_a Hash
    end

    it 'returns a list of MAC addresses' do
      expect(device.details[:macs]).to match_array(
        [ 'aa:bb:cc:dd:ee:01', 'aa:bb:cc:dd:ee:02', 'aa:bb:cc:dd:ee:03' ]
      )
    end

    it 'returns a list of IP addresses' do
      expect(device.details[:ips]).to match_array(
        [ '10.10.10.1', '192.168.99.99', '8.8.8.8' ]
      )
    end

    it 'returns details from the plugin' do
      expect(device.details).to include(
        'key1' => 'value1', 'key2' => 'value2'
      )
    end
  end

  describe 'database constraints' do
    let(:device) {
      Device.create(
        name: 'Test device',
        macs: [Mac.create(mac: 'aa:bb:cc:dd:ee:01'), Mac.create(mac: 'aa:bb:cc:dd:ee:02'), Mac.create(mac: 'aa:bb:cc:dd:ee:03')],
        ips: [Ip.create(ip: '10.10.10.1'), Ip.create(ip: '192.168.99.99'), Ip.create(ip: '8.8.8.8')]
      )
    }

    before(:each) do
      # 'let' is lazy-evaluated.
      # Without this save the expects will get the count wrong.
      device.save
    end

    it 'deletes IP address when a device is deleted' do
      expect{device.destroy}.to change(Ip, :count).by -3
      expect(Ip.where(ip: [
        '10.10.10.1',
        '192.168.99.99',
        '8.8.8.8'])).to eq []
    end

    it 'deletes MAC address when a device is deleted' do
      expect{device.destroy}.to change(Mac, :count).by -3
      expect(Mac.where(mac: [
        'aa:bb:cc:dd:ee:01',
        'aa:bb:cc:dd:ee:02',
        'aa:bb:cc:dd:ee:03'])).to eq []
    end
  end

  describe '#heartbeat' do
    let(:device) { Device.create }
    let(:reporting_device) { Device.create }

    it 'sets a heartbeat' do
      expect{ device.heartbeat }.to change(Heartbeat, :count).by 1
      expect(Heartbeat.last.device).to eq device
      expect(Heartbeat.last.reporting_device).to eq device
    end

    it 'sets a heartbeat reported by another device' do
      expect{ device.heartbeat(reported_by: reporting_device) }.to change(Heartbeat, :count).by 1
      expect(Heartbeat.last.device).to eq device
      expect(Heartbeat.last.reporting_device).to eq reporting_device
    end
  end

  describe '#seconds_since_heartbeat' do
    let(:device) { Device.create }

    it 'gets the number of seconds since heartbeat' do
      device.heartbeat
      Timecop.freeze(Time.now + 30) do
        expect(device.seconds_since_heartbeat).to eq 30
      end
    end

    it 'gets the number of seconds since the most recent heartbeat' do
      Timecop.freeze(Time.now - 30) do
        device.heartbeat
      end
      device.heartbeat
      Timecop.freeze(Time.now + 30) do
        expect(device.seconds_since_heartbeat).to eq 30
      end
    end

    it 'returns nil for no heartbeat' do
      device.save
      expect(device.seconds_since_heartbeat).to be_nil
    end
  end

  describe '#execute_action' do
    let(:device) { Device.create }
    let(:action1) {
      {
        device_id: device.id,
        action_type: 'first_type',
        body: 'first action body'
      }
    }
    let(:action2) {
      {
        device_id: device.id,
        action_type: 'second_type',
        body: 'second action body'
      }
    }
    let(:action3) {
      {
        device_id: device.id,
        action_type: 'third_type',
        body: 'third action body'
      }
    }
    let(:executed_action) {
      {
        device_id: device.id,
        action_type: 'first_type',
        body: 'first action body',
        executed_at: Time.now
      }
    }

    it 'returns an nil if there are not queued actions' do
      expect(device.execute_action).to be_nil
    end

    it 'returns an action' do
      ac = DeviceAction.create( action1 )
      expect(device.execute_action).to eq ac
    end

    it 'returns the first action' do
      ac1 = DeviceAction.create( action1 )
      Timecop.freeze(Time.now + 30) do
        ac2 = DeviceAction.create( action2 )
      end
      expect(device.execute_action).to eq ac1
    end

    it 'sets the executed time' do
      ac = DeviceAction.create( action1 )
      device.execute_action
      expect(ac.reload.executed_at).to_not be_nil
    end

    it 'does not return an executed action' do
      ac = DeviceAction.create( executed_action )
      expect(device.execute_action).to be_nil
    end

    it 'returns several actions in order' do
      ac1 = DeviceAction.create( action1 )
      ac2 = ac3 = nil
      Timecop.freeze(Time.now + 30) do
        ac2 = DeviceAction.create( action2 )
      end
      Timecop.freeze(Time.now + 60) do
        ac3 = DeviceAction.create( action3 )
      end
      expect(device.execute_action).to eq ac1
      expect(device.execute_action).to eq ac2
      expect(device.execute_action).to eq ac3
      expect(device.execute_action).to be_nil
    end
  end

  describe '#add_relation' do
    let(:device1) { Device.create }
    let(:device2) { Device.create }
    let(:device3) { Device.create }

    it 'adds a relationship' do
      expect{
        device1.add_relation('relationship type', device2)
      }.to change(Relationship, :count).by 1
    end

    it 'sets the primary of a relationship' do
      device1.add_relation('relationship type', device2)
      expect(Relationship.last.primary).to eq device1
    end

    it 'sets the secondary of a relationship' do
      device1.add_relation('relationship type', device2)
      expect(Relationship.last.secondary).to eq device2
    end

    it 'sets the relation of a relationship' do
      device1.add_relation('relationship type', device2)
      expect(Relationship.last.relation).to eq 'relationship type'
    end

    it 'does not create a duplicate relationship' do
      device1.add_relation('relationship type', device2)
      expect{
        device1.add_relation('relationship type', device2)
      }.to change(Relationship, :count).by 0
    end

    it 'creates a second relation with the same devices' do
      device1.add_relation('relationship type', device2)
      expect{
        device1.add_relation('relationship type 2', device2)
      }.to change(Relationship, :count).by 1
    end

    it 'creates a relation with a second primary device' do
      device1.add_relation('relationship type', device2)
      expect{
        device3.add_relation('relationship type', device2)
      }.to change(Relationship, :count).by 1
    end

    it 'creates a relation with a second secondary device' do
      device1.add_relation('relationship type', device2)
      expect{
        device1.add_relation('relationship type', device3)
      }.to change(Relationship, :count).by 1
    end
  end

  describe '#delete_relation' do
    let(:device1) { Device.create }
    let(:device2) { Device.create }
    let(:device3) { Device.create }
    let(:relation1) { Relationship.create(primary: device1, secondary: device2, relation: 'relation one') }
    let(:relation2) { Relationship.create(primary: device1, secondary: device3, relation: 'relation two') }
    let(:relation3) { Relationship.create(primary: device1, secondary: device2, relation: 'relation two') }

    before(:each) do
      # Preload
      relation1
      relation2
      relation3
    end

    it 'removes a relation' do
      expect{
        device1.delete_relation('relation one', device2)
      }.to change(Relationship, :count).by -1
    end

    it 'removes the correct relation' do
      id = relation1.id
      device1.delete_relation('relation one', device2)
      expect{Relationship.find(id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not remove a non-existant relation' do
      expect{
        device1.delete_relation('relation one', device3)
      }.to change(Relationship, :count).by 0
    end

    it 'only removes correct relationship for device' do
      id1 = relation1.id
      id2 = relation3.id
      expect{
        device1.delete_relation('relation two', device2)
      }.to change(Relationship, :count).by -1
      expect(Relationship.find(id1)).to eq relation1
      expect{Relationship.find(id2)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'only removes correct relationship for relation' do
      id1 = relation2.id
      id2 = relation3.id
      expect{
        device1.delete_relation('relation two', device3)
      }.to change(Relationship, :count).by -1
      expect{Relationship.find(id1)}.to raise_error(ActiveRecord::RecordNotFound)
      expect(Relationship.find(id2)).to eq relation3
    end
  end
end
