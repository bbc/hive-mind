require 'rails_helper'

module HiveMindGeneric
  RSpec.describe Plugin, type: :model do
    describe '#name' do
      let(:dev1) { HiveMindGeneric::Plugin.create }
      let(:dev2) { HiveMindGeneric::Plugin.create }

      it 'generates a name for the device' do
        expect(dev1.name).to_not be_nil
      end

      it 'generates different names for each device' do
        expect(dev1.name).to_not eq dev2.name
      end
    end
  end
end
