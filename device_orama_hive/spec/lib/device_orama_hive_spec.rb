require 'spec_helper'

describe DeviceOramaHive do
  describe '#find_or_create_by' do
    let(:valid_options) {
      {
        hostname: 'hive_host',
        ip: '10.10.10.10'
      }
    }

    it 'creates an attribute instance' do
      expect(DeviceOramaHive.find_or_create_by(valid_options)).to be_an Attribute
    end
  end
end
