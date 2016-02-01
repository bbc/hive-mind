require 'rails_helper'

module HiveMindHive
  RSpec.describe Plugin, type: :model do
    describe '#create' do
      it 'sets the version of the hive' do
        expect(Plugin.create(
          'hostname' => 'test_host_name',
          'version' => '2.3.4'
        ).version).to eq '2.3.4'
      end

      it 'sets runner plugins of the hive' do
        expect(Plugin.create(
          'hostname' => 'test_host_name',
          'runner_plugins' => { 'plugin1' => '2.4.8', 'plugin2' => '99.9' }
        ).runner_plugins).to match(
          { 'plugin1' => '2.4.8', 'plugin2' => '99.9' }
        )
      end
    end

    describe '#update' do
      it 'updates the version of the hive' do
        hive = Plugin.create(
          'hostname' => 'test_host_name',
          'version' => '2.3.4'
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

    context 'runner version' do
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

        it 'does not unecessarily update the version of the hive' do
          hive # Preload
          expect{hive.update_version('1.2.3')}.to change(HiveMindHive::RunnerVersionHistory, :count).by 0
        end
      end
    end

    context 'runner plugins' do
      let(:hive_no_plugins) {
        Plugin.create(hostname: 'hive_no_plugins')
      }

      let(:runner_plugin_version1) {
        RunnerPluginVersion.create(
          name: 'plugin1',
          version: '2.4.8'
        )
      }

      let(:runner_plugin_version2) {
        RunnerPluginVersion.create(
          name: 'plugin2',
          version: '5'
        )
      }

      let(:runner_plugin_version3) {
        RunnerPluginVersion.create(
          name: 'plugin3',
          version: '1.0a'
        )
      }

      let(:hive_one_plugin) {
        Plugin.create(
          hostname: 'hive_no_plugins',
          runner_plugin_version_history: [
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version1,
              start_timestamp: Time.now
            )
          ]
        )
      }

      let(:hive_three_plugins) {
        Plugin.create(
          hostname: 'hive_no_plugins',
          runner_plugin_version_history: [
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version1,
              start_timestamp: Time.now
            ),
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version2,
              start_timestamp: Time.now
            ),
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version3,
              start_timestamp: Time.now
            )
          ]
        )
      }

      describe '#runner_plugins' do
        it 'returns an empty list of plugins' do
          expect(hive_no_plugins.runner_plugins).to eq({})
        end

        it 'returns a single plugin with version' do
          expect(hive_one_plugin.runner_plugins).to eq({ 'plugin1' => '2.4.8' })
        end

        it 'returns multiple plugins with versions' do
          expect(hive_three_plugins.runner_plugins).to match(
            {
              'plugin1' => '2.4.8',
              'plugin2' => '5',
              'plugin3' => '1.0a'
            }
          )
        end
      end

      describe '#update_runner_plugins' do
        it 'changes the reported version of a single plugin' do
          hive_one_plugin.update_runner_plugins(
            'plugin1' => '2.4.9'
          )
          expect(hive_one_plugin.runner_plugins).to eq({ 'plugin1' => '2.4.9' })
        end

        it 'changes the reported versions of multiple plugins' do
          hive_three_plugins.update_runner_plugins(
            'plugin1' => '2.4.9', 'plugin2' => '7', 'plugin3' => '1.0b'
          )
          expect(hive_three_plugins.runner_plugins).to match(
            {
              'plugin1' => '2.4.9',
              'plugin2' => '7',
              'plugin3' => '1.0b'
            }
          )
        end

        it 'adds a new plugin' do
          hive_three_plugins.update_runner_plugins(
            'plugin1' => '2.4.8', 'plugin2' => '5', 'plugin3' => '1.0a', 'plugin4' => '99'
          )
          expect(hive_three_plugins.runner_plugins).to match(
            {
              'plugin1' => '2.4.8',
              'plugin2' => '5',
              'plugin3' => '1.0a',
              'plugin4' => '99',
            }
          )
        end

        it 'removes a new plugin' do
          hive_three_plugins.update_runner_plugins(
            'plugin1' => '2.4.8', 'plugin2' => '5'
          )
          expect(hive_three_plugins.runner_plugins).to match(
            {
              'plugin1' => '2.4.8',
              'plugin2' => '5',
            }
          )
        end

        it 'sets the end timestamp of the previous version in the history' do
          hive_one_plugin.update_runner_plugins('plugin1' => '2.4.9')
          expect(hive_one_plugin.runner_plugin_version_history[0].end_timestamp).to_not be_nil
        end

        it 'does not unecessarily update the version of a plugin (single plugin)' do
          hive_one_plugin # Preload
          expect{hive_one_plugin.update_runner_plugins('plugin1' => '2.4.8')}.to change(HiveMindHive::RunnerPluginVersionHistory, :count).by 0
        end

        it 'does not unecessarily update the version of a plugin (multiple plugins)' do
          hive_three_plugins # Preload
          expect{hive_three_plugins.update_runner_plugins('plugin1' => '2.4.8', 'plugin2' => '6', 'plugin3' => '1.0b')}.to change(HiveMindHive::RunnerPluginVersionHistory, :count).by 2
        end

        it 'does not unecessarily update the version of a plugin (adding plugins)' do
          hive_three_plugins # Preload
          expect{hive_three_plugins.update_runner_plugins('plugin1' => '2.4.8', 'plugin2' => '5', 'plugin3' => '1.0a', 'plugin4' => '99')}.to change(HiveMindHive::RunnerPluginVersionHistory, :count).by 1
        end
      end
    end

    describe '#details' do
      let(:runner_version) {
        RunnerVersion.create( version: '1.2.3' )
      }
      let(:runner_plugin_version1) {
        RunnerPluginVersion.create(
          name: 'plugin1',
          version: '2.4.8'
        )
      }

      let(:runner_plugin_version2) {
        RunnerPluginVersion.create(
          name: 'plugin2',
          version: '5'
        )
      }

      let(:runner_plugin_version3) {
        RunnerPluginVersion.create(
          name: 'plugin3',
          version: '1.0a'
        )
      }

      let(:hive) {
        Plugin.create(
          hostname: 'hive_host_name',
          runner_version_history: [
            RunnerVersionHistory.create(
              runner_version: runner_version,
              start_timestamp: Time.now
            )
          ],
          runner_plugin_version_history: [
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version1,
              start_timestamp: Time.now
            ),
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version2,
              start_timestamp: Time.now
            ),
            RunnerPluginVersionHistory.create(
              runner_plugin_version: runner_plugin_version3,
              start_timestamp: Time.now
            )
          ]
        )
      }

      it 'returns the version number' do
        expect(hive.details).to include({'version' => '1.2.3'})
      end

      it 'returns the plugin version numbers' do
        expect(hive.details.keys).to include 'runner_plugins'
        expect(hive.details['runner_plugins']).to match(
          {
            'plugin1' => '2.4.8',
            'plugin2' => '5',
            'plugin3' => '1.0a'
          }
        )
      end
    end

    describe '#json_keys' do
      let(:plugin) { Plugin.create }

      it 'returns the correct array' do
        expect(plugin.json_keys).to eq([:version, :connected_devices])
      end
    end
  end
end
