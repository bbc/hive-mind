require 'rails_helper'

module DeviceOramaHive
  RSpec.describe Attribute, type: :model do
    describe '#name' do
      let(:hive_attributes) {
        Attribute.create( hostname: 'hive_host_name' )
      }

      it 'returns the hostname' do
        expect(hive_attributes.name).to eq 'hive_host_name'
      end
    end
  end
end
