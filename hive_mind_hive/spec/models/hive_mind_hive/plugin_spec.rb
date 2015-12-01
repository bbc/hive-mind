require 'rails_helper'

module HiveMindHive
  RSpec.describe Plugin, type: :model do
    describe '#create' do
      it 'sets the version of the hive' do
        expect(Plugin.create(
          hostname: 'test_host_name',
          version: '2.3.4'
        ).version).to eq '2.3.4'
      end
    end

    describe '#update' do
      it 'updates the version of the hive' do
        hive = Plugin.create(
          hostname: 'test_host_name',
          version: '2.3.4'
        )
        hive.update(version: '2.3.5')
        expect(hive.version).to eq '2.3.5'
      end
    end

    describe '#name' do
      let(:hive_plugin) {
        Plugin.create( hostname: 'hive_host_name' )
      }

      it 'returns the hostname' do
        expect(hive_plugin.name).to eq 'hive_host_name'
      end
    end

    let(:runner_version) {
      RunnerVersion.create( version: '1.2.3' )
    }
    let(:hive) {
      Plugin.create(
        hostname: 'hive_host_name',
        runner_version_history: [
          RunnerVersionHistory.create(
            runner_version: runner_version,
            start_timestamp: Time.now
          )
        ]
      )
    }
    let(:hive_no_history) {
      Plugin.create(hostname: 'hive_host_name_2')
    }

    describe '#version' do
      it 'returns nil version if there is no history' do
        expect(hive_no_history.version).to be_nil
      end

      it 'returns the version number' do
        expect(hive.version).to eq '1.2.3'
      end
    end

    describe '#update_version' do
      it 'changes the reported version' do
        hive.update_version('1.2.4')
        expect(hive.version).to eq '1.2.4'
      end

      it 'sets the end timestamp of the previous version in the history' do
        hive.update_version('1.2.4')
        expect(hive.runner_version_history[0].end_timestamp).to_not be_nil
      end

      it 'sets a first version in history' do
        hive_no_history.update_version('1.2.4')
        expect(hive_no_history.version).to eq '1.2.4'
      end
    end

    describe '#details' do
      it 'returns the version number' do
        expect(hive.details).to include({'version' => '1.2.3'})
      end
    end
  end
end
