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
end
