require 'rails_helper'

module HiveMindGeneric
  RSpec.describe Plugin, type: :model do
    describe '.create' do
      it 'sets an characteristic' do
        expect {
          HiveMindGeneric::Plugin.create( attr1: 'value' )
        }.to change(HiveMindGeneric::Characteristic, :count).by 1
      end

      it 'sets multiple characteristics' do
        expect {
          HiveMindGeneric::Plugin.create( attr1: 'value1', attr2: 'value2', attr3: 'value3' )
        }.to change(HiveMindGeneric::Characteristic, :count).by 3
      end
    end

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

    describe '#details' do
      it 'returns a hash of characteristics' do
        dev = HiveMindGeneric::Plugin.create(
                attr1: 'value1',
                attr2: 'value2',
                attr3: 'value3'
              )
        expect(dev.details).to match(
          {
            'attr1' => 'value1',
            'attr2' => 'value2',
            'attr3' => 'value3'
          }
        )

      end
    end
  end
end
