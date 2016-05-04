require 'rails_helper'

RSpec.describe HiveHelper, type: :helper do
  describe '#all_hives' do

    let(:hive_type) { DeviceType.create(classification: 'Hive') }
    let(:non_hive_type) { DeviceType.create(classification: 'Type') }
    let(:hive_model) { Model.create(device_type: hive_type) }
    let(:non_hive_model) { Model.create(device_type: non_hive_type) }

    let(:hive_one) { Device.create(model: hive_model) }
    let(:device_one) { Device.create(model: non_hive_model) }
    let(:hive_two) { Device.create(model: hive_model) }
    let(:device_two) { Device.create(model: non_hive_model) }

    before(:each) do
      # Pre-load
      hive_one
      device_one
      hive_two
      device_two
    end

    it 'returns a list of all hive devices' do
      expect(all_hives).to match_array([hive_one, hive_two])
    end
  end
end
