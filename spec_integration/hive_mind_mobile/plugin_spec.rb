require 'rails_helper'

RSpec.describe HiveMindMobile::Plugin, type: :model do
  describe '#identify_existing' do
    let(:mobile) {
      HiveMindMobile::Plugin.create(serial: 'abc123')
    }
    let(:mac1) { Mac.create(mac: '00:00:00:00:00:01') }
    let(:mac2) { Mac.create(mac: '00:00:00:00:00:02') }
    let(:dev) {
      Device.create(
        macs: [ mac1 ],
        plugin: mobile
      )
    }

    before(:each) do
      dev.save
    end

    it 'identifies an existing mobile device' do
      expect(Device.identify_existing(device_type: 'mobile', serial: 'abc123', macs: [ mac2 ])).to eq dev
    end

    it 'does not identify an unknown mobile device' do
      expect(Device.identify_existing(device_type: 'mobile', serial: 'abc124', macs: [ mac2 ])).to be_nil
    end
  end
end
