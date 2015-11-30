require 'rails_helper'

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
end
