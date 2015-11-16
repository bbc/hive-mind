require 'rails_helper'

module HiveMindHive
  RSpec.describe Plugin, type: :model do
    describe '#name' do
      let(:hive_plugin) {
        Plugin.create( hostname: 'hive_host_name' )
      }

      it 'returns the hostname' do
        expect(hive_plugin.name).to eq 'hive_host_name'
      end
    end
  end
end
