require 'rails_helper'
require 'timecop'

RSpec.describe Api::DevicesController, type: :controller do
  let(:valid_attributes) {
    {
      name: 'Device 1'
    }
  }

  let(:valid_attributes_with_id) {
    {
      name: 'Device 1',
      id: 987
    }
  }

  let(:device_with_mac1) {
    {
      name: 'Device 1',
      macs: [ 'aa:bb:cc:dd:ee:01' ]
    }
  }

  let(:device_with_mac2) {
    {
      name: 'Device 2',
      macs: [ 'aa:bb:cc:dd:ee:02' ]
    }
  }

  let(:valid_session) { {} }

  describe 'POST #register' do
    it 'registers a new device without unique identifier' do
      expect {
        post :register, {device: valid_attributes}, valid_session
      }.to change(Device, :count).by(1)
    end

    it 'does not reregister a known device' do
      device = Device.create! valid_attributes
      expect {
        post :register, {device: valid_attributes.merge(id: device.id)}, valid_session
      }.to change(Device, :count).by(0)
    end

    it 'does not register an unknown device only by id' do
      expect {
        post :register, {device: { id: 99 }}, valid_session
      }.to change(Device, :count).by(0)
    end

    it 'registers two devices with different MACs' do
      post :register, {device: device_with_mac1}, valid_session
      expect {
        post :register, {device: device_with_mac2}, valid_session
      }.to change(Device, :count).by(1)
    end

    it 'identifies device by MAC' do
      post :register, {device: device_with_mac1}, valid_session
      expect {
        post :register, {device: device_with_mac1}, valid_session
      }.to change(Device, :count).by(0)
    end

    it 'does not create an empty MAC for an empty string' do
      post :register, {device: { macs: [ '' ] } }, valid_session
      expect(Device.last.macs.length).to be 0
    end

    it 'does not create an empty MAC for nil value' do
      post :register, {device: { macs: [ nil ] } }, valid_session
      expect(Device.last.macs.length).to be 0
    end

    it 'does not create an empty MAC for missing macs array' do
      post :register, {device: { name: 'Device' } }, valid_session
      expect(Device.last.macs.length).to be 0
    end

    it 'sets the heartbeat' do
      post :register, {device: valid_attributes}, valid_session
      Timecop.freeze(Time.now + 30) do
        expect(Device.last.seconds_since_heartbeat).to eq 30
      end
    end

    it 'registers a devices with an unknown id' do
      expect {
        post :register, {device: valid_attributes_with_id}, valid_session
      }.to change(Device, :count).by(1)
    end

    context 'unknown device type' do
      let(:unknown_device_type) {
        {
          device_type: :unknown,
          name: 'Unknown device'
        }
      }

      it 'registeres the unknown device' do
        expect {
          post :register, {device: unknown_device_type}, valid_session
        }.to change(Device, :count).by(1)
      end

      it 'sets the device type as nil' do
        post :register, {device: unknown_device_type}, valid_session
        expect(Device.last.plugin_type).to be_nil
      end

      it 'sets the device data id as nil' do
        post :register, {device: unknown_device_type}, valid_session
        expect(Device.last.plugin_id).to be_nil
      end
    end

    context 'known device type' do
      let(:known_device_type) {
        {
          model: :test_model,
          brand: :test_brand,
          device_type: :generic,
          name: 'Known device',
          extra_data_one: 'Data one',
          extra_data_two: 2
        }
      }

      let(:device_without_name) {
        {
          model: :test_model,
          brand: :test_brand,
          device_type: :generic
        }
      }

      let(:device_with_name) {
        {
          model: :test_model,
          brand: :test_brand,
          device_type: :generic,
          name: 'User defined device name'
        }
      }

      let(:device_with_os) {
        {
          model: :test_model,
          brand: :test_brand,
          operating_system_name: 'Test OS',
          operating_system_version: '1.2.3'
        }
      }

      it 'registeres the known device' do
        expect {
          post :register, {device: known_device_type}, valid_session
        }.to change(Device, :count).by(1)
      end

      it 'sets the device type' do
        post :register, {device: known_device_type}, valid_session
        expect(Device.last.device_type).to eq 'generic'
      end

      it 'passes through attributes' do
        post :register, {device: known_device_type}, valid_session
        plugin = Device.last.plugin
        expect(plugin.details['extra_data_one']).to eq 'Data one'
        expect(plugin.details['extra_data_two']).to eq '2'
        expect(plugin.details['extra_data_three']).to be_nil
      end

      it 'generates a name from engine' do
        post :register, {device: device_without_name}, valid_session
        expect(Device.last.name).to_not be_nil
      end

      it 'overrides name set by engine' do
        post :register, {device: device_with_name}, valid_session
        expect(Device.last.name).to eq 'User defined device name'
      end

      it 'sets the operating system' do
        post :register, {device: device_with_os}, valid_session
        expect(Device.last.operating_system.name).to eq 'Test OS'
        expect(Device.last.operating_system.version).to eq '1.2.3'
      end

      context 'existing device' do
        let(:device_instance) { Device.new }
        before(:each) {
          device_instance.set_os(name: 'Old OS', version: '1.2.3')
        }

        it 'updates the operating system' do
          post :register, {device: { id: device_instance.id, operating_system_name: 'New OS', operating_system_version: '2.4.6' } }
          device_instance.reload
          expect(device_instance.operating_system.name).to eq 'New OS'
          expect(device_instance.operating_system.version).to eq '2.4.6'
        end

        it 'does not modify the operating system' do
          post :register, {device: { id: device_instance.id } }
          device_instance.reload
          expect(device_instance.operating_system.name).to eq 'Old OS'
          expect(device_instance.operating_system.version).to eq '1.2.3'
        end
      end
    end

    context 'device models, types and brands' do
      let(:brand1_model1) {
        {
          name: 'Device 1',
          model: 'Model 1',
          brand: 'Brand 1',
        }
      }

      let(:brand1_model2) {
        {
          name: 'Device 2',
          model: 'Model 2',
          brand: 'Brand 1',
        }
      }

      let(:brand2_model1) {
        {
          name: 'Device 3',
          model: 'Model 1',
          brand: 'Brand 2',
        }
      }

      let(:brand2_model2) {
        {
          name: 'Device 4',
          model: 'Model 2',
          brand: 'Brand 2',
        }
      }

      let(:brand1_model1_type1) {
        {
          name: 'Device 5',
          model: 'Model 1',
          brand: 'Brand 1',
          device_type: 'Type 1',
        }
      }

      let(:brand1_model1_type2) {
        {
          name: 'Device 6',
          model: 'Model 1',
          brand: 'Brand 1',
          device_type: 'Type 2',
        }
      }

      it 'creates a new model' do
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Model, :count).by(1)
      end

      it 'creates a new brand' do
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Brand, :count).by(1)
      end

      it 'creates a new model for an existing brand' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model2}, valid_session
        }.to change(Model, :count).by(1)
      end

      it 'creates a new brand with an existing model name' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand2_model1}, valid_session
        }.to change(Brand, :count).by(1)
      end

      it 'it does not recreate a known model' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Model, :count).by(0)
      end

      it 'it does not recreate a known brand for a known model' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model1}, valid_session
        }.to change(Brand, :count).by(0)
      end

      it 'it does not recreate a known brand for a new model' do
        post :register, {device: brand1_model1}, valid_session
        expect {
          post :register, {device: brand1_model2}, valid_session
        }.to change(Brand, :count).by(0)
      end

      it 'creates a new type' do
        expect {
          post :register, {device: brand1_model1_type1}, valid_session
        }.to change(DeviceType, :count).by(1)
      end

      it 'does not recreate an existing type' do
        post :register, {device: brand1_model1_type1}, valid_session
        expect {
          post :register, {device: brand1_model1_type1}, valid_session
        }.to change(DeviceType, :count).by(0)
      end

      it 'creates a new type for an existing model and brand' do
        post :register, {device: brand1_model1_type1}, valid_session
        expect {
          post :register, {device: brand1_model1_type2}, valid_session
        }.to change(DeviceType, :count).by(1)
      end

      it 'creates a new model for an existing model/brand with a new type' do
        post :register, {device: brand1_model1_type1}, valid_session
        expect {
          post :register, {device: brand1_model1_type2}, valid_session
        }.to change(Model, :count).by(1)
      end
    end

    context 'plugin with device identifier method' do
      let(:device) {
        {
          name: 'Device',
          model: 'Model',
          brand: 'Brand',
          device_type: 'Controllermockone',
        }
      }

      module HiveMindControllermockone
        class Plugin < HiveMindGeneric::Plugin
          def self.identify_existing options = {}
            if identifier = HiveMindGeneric::Characteristic.find_by(key: 'id_key', value: options[:id_key])
              identifier.plugin.device
            else
              nil
            end
          end
          def self.plugin_params params
            params.permit(:id_key)
          end
        end
      end

      it 'identifies device based on plugin identifier method' do
        post :register, {device: device.merge(
                                   id_key: '12468',
                                   macs: ['aa:aa:aa:aa:aa:01']
                                 )}, valid_session
        expect {
          post :register, {device: device.merge(
                                     id_key: '12468',
                                     macs: ['aa:aa:aa:aa:aa:02']
                                   )}, valid_session
        }.to change(Device, :count).by(0)
      end

      it 'creates new device with different unique identifier' do
        post :register, {device: device.merge(
                                   id_key: '12468',
                                   macs: ['aa:aa:aa:aa:aa:01']
                                 )}, valid_session
        expect {
          post :register, {device: device.merge(
                                   id_key: '12469',
                                   macs: ['aa:aa:aa:aa:aa:02']
                                 )}, valid_session
        }.to change(Device, :count).by(1)
        expect {
          post :register, {device: device.merge(
                                   id_key: '12470',
                                   macs: ['aa:aa:aa:aa:aa:01']
                                 )}, valid_session
        }.to change(Device, :count).by(1)
      end
    end

    context 'plugin with existing device' do
      let(:device_info) {
        {
          name: 'Device',
          device_type: 'Controllermockupdating',
          macs: [ 'aa:bb:cc:dd:ee:01' ]
        }
      }
      let(:device_no_plugin_info) {
        {
          name: 'Device (no plugin)',
          macs: [ 'aa:bb:cc:dd:ee:02' ]
        }
      }
      module HiveMindControllermockupdating
        class Plugin < HiveMindGeneric::Plugin
          def update(*args)
            @@indicator = 'updated'
          end
          def self.plugin_params args
            {}
          end
          def self.indicator
            @@indicator
          end
        end
      end

      let(:device_type) { DeviceType.new(classification: 'Controllermockupdating') }
      let(:model) { Model.new(device_type: device_type) }

      let(:device) {
        Device.create(
          name: 'Device',
          model: model,
          macs: [ Mac.new(mac:'aa:bb:cc:dd:ee:01')],
          plugin: HiveMindControllermockupdating::Plugin.new,
          plugin_type: 'HiveMindControllermockupdating::Plugin'
        )
      }

      let(:device_no_plugin) {
        Device.create(
          name: 'Device (no plugin)',
          macs: [ Mac.new(mac:'aa:bb:cc:dd:ee:02')],
        )
      }

      it 'calls the plugin update method' do
        post :register, {device: device_info.merge( device_id: device.id )}
        expect(HiveMindControllermockupdating::Plugin.indicator).to eq 'updated'
      end

      it 'updates a devices with no plugin set' do
        post :register, {device: device_no_plugin_info.merge( device_id: device_no_plugin.id )}
        expect(response).to have_http_status(:accepted)

      end
    end
  end

  describe 'PUT #poll' do
    let(:brand) { Brand.create(name: 'Test brand') }
    let(:model) { Model.create(name: 'Test model', brand: brand) }
    let(:device) { Device.create(name: 'Test device', model: model) }
    let(:device2) { Device.create(name: 'Test device 2') }
    let(:device3) { Device.create(name: 'Test device 3') }
    let(:reporting_device) { Device.create(name: 'Reporting device') }
    it 'adds a heartbeat for a known device' do
      expect {
        put :poll, { poll: { id: device.id } }
      }.to change(Heartbeat, :count).by(1)
    end

    it 'sets the heartbeat for the correct device' do
      put :poll, { poll: { id: device.id } }
      expect(Heartbeat.last.device).to eq device
    end

    it 'sets the reporting device for a self reporting device' do
      put :poll, { poll: { id: device.id } }
      expect(Heartbeat.last.reporting_device).to eq device
    end

    it 'sets the device of a hearbeat when reported by a different device' do
      put :poll, { poll: { devices: [ device.id ], id: reporting_device.id } }
      expect(Heartbeat.last.device).to eq device
    end

    it 'sets the reporting device as different from the device' do
      put :poll, { poll: { devices: [ device.id ], id: reporting_device.id } }
      expect(Heartbeat.last.reporting_device).to eq reporting_device
    end

    it 'polls multiple devices' do
      expect {
        put :poll, { poll: { devices: [ device.id, device2.id, device3.id ], id: reporting_device.id } }
      }.to change(Heartbeat, :count).by(3)
      expect(Heartbeat.last(3).map{ |h| h.device }).to match [ device, device2, device3 ]
    end

    it 'fails to set a heartbeat for an unknown device' do
      expect {
        put :poll, { poll: { id: -1 } }
      }.to change(Heartbeat, :count).by(0)
    end

    it 'report an unknown device correctly' do
      put :poll, { poll: { id: -1 } }
      expect(response).to have_http_status(:not_found)
    end

    it 'report an unknown reporting device correctly' do
      put :poll, { poll: { devices: [ device.id ], id: -1 } }
      expect(response).to have_http_status(:not_found)
    end

    context 'with actions' do
      let(:valid_options) {
        {
          device_id: device.id,
          action_type: 'redirect',
          body: 'http://test_url.com'
        }
      }

      it 'returns an action with the poll response' do
        put :action, { device_action: valid_options }
        put :poll, { poll: { id: device.id, poll_type: 'active' } }
        expect(assigns(:device_action)).to eq DeviceAction.last
      end

      it 'returns an action with the poll response (default poll type)' do
        put :action, { device_action: valid_options }
        put :poll, { poll: { id: device.id } }
        expect(assigns(:device_action)).to eq DeviceAction.last
      end

      it 'does not return an action for a passive poll' do
        put :action, { device_action: valid_options }
        put :poll, { poll: { id: device.id, poll_type: 'passive' } }
        expect(assigns(:device_action)).to be_nil
      end

      context 'polled by another device' do
        it 'returns an action with the poll response' do
          put :action, { device_action: valid_options }
          put :poll, { poll: { id: device2.id, devices: [ device.id], poll_type: 'active' } }
          expect(assigns(:device_actions)[device.id]).to eq DeviceAction.last
        end

        it 'returns an action with the poll response (default poll type)' do
          put :action, { device_action: valid_options }
          put :poll, { poll: { id: device2.id, devices: [ device.id] } }
          expect(assigns(:device_actions)[device.id]).to eq DeviceAction.last
        end

        it 'does not return an action for a passive poll' do
          put :action, { device_action: valid_options }
          put :poll, { poll: { id: device2.id, devices: [ device.id ],  poll_type: 'passive' } }
          expect(assigns(:device_actions)[device.id]).to be_nil
        end
      end
    end
  end

  describe 'PUT #action' do
    let(:device) { Device.create(name: 'Test device') }
    let(:device2) { Device.create(name: 'Test device 2') }
    let(:valid_options) {
      {
        device_id: device.id,
        action_type: 'redirect',
        body: 'http://test_url.com'
      }
    }
    let(:missing_device_id) {
      {
        action_type: 'redirect',
        body: 'http://test_url.com'
      }
    }
    let(:missing_type) {
      {
        device_id: device.id,
        body: 'http://test_url.com'
      }
    }
    let(:missing_body) {
      {
        device_id: device.id,
        action_type: 'redirect',
      }
    }

    let(:valid_options_2) {
      {
        device_id: device2.id,
        action_type: 'redirect',
        body: 'http://test_url.com'
      }
    }

    let(:valid_options_3) {
      {
        device_id: device.id,
        action_type: 'display',
        body: 'http://test_url.com'
      }
    }

    let(:valid_options_4) {
      {
        device_id: device.id,
        action_type: 'redirect',
        body: 'http://test_url_2.com'
      }
    }

    it 'adds an action' do
      expect {
        put :action, { device_action: valid_options }
      }.to change(DeviceAction, :count).by 1
    end

    it 'adds an action for the given device' do
      put :action, { device_action: valid_options }
      expect(DeviceAction.last.device).to eq device
    end

    it 'sets the action type and body' do
      put :action, { device_action: valid_options }
      expect(DeviceAction.last.action_type).to eq 'redirect'
      expect(DeviceAction.last.body).to eq 'http://test_url.com'
    end

    it 'sets the executed time to nil' do
      put :action, { device_action: valid_options }
      expect(DeviceAction.last.executed_at).to be_nil
    end

    it 'adds a second action for a different device' do
      put :action, { device_action: valid_options }
      expect {
        put :action, { device_action: valid_options_2 }
      }.to change(DeviceAction, :count).by 1
    end

    it 'adds a second action of a different type action' do
      put :action, { device_action: valid_options }
      expect {
        put :action, { device_action: valid_options_3 }
      }.to change(DeviceAction, :count).by 1
    end

    it 'adds a second action with a different body' do
      put :action, { device_action: valid_options }
      expect {
        put :action, { device_action: valid_options_4 }
      }.to change(DeviceAction, :count).by 1
    end

    it 'does not duplicate an action before it is executed' do
      put :action, { device_action: valid_options }
      expect {
        put :action, { device_action: valid_options }
      }.to change(DeviceAction, :count).by 0
      expect(response).to have_http_status(:already_reported)
    end

    it 'allows a duplicate action after it has been executed' do
      put :action, { device_action: valid_options }
      put :poll, { poll: { id: device.id } }
      expect {
        put :action, { device_action: valid_options }
      }.to change(DeviceAction, :count).by 1
    end

    it 'does not duplicate a retried action before it is executed' do
      put :action, { device_action: valid_options }
      put :poll, { poll: { id: device.id } }
      put :action, { device_action: valid_options }
      expect {
        put :action, { device_action: valid_options }
      }.to change(DeviceAction, :count).by 0
      expect(response).to have_http_status(:already_reported)
    end

    it 'does not add an action with a missing device id' do
      expect {
        put :action, { device_action: missing_device_id }
      }.to change(DeviceAction, :count).by 0
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not add an action with a missing type' do
      expect {
        put :action, { device_action: missing_type }
      }.to change(DeviceAction, :count).by 0
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not add an action with a missing body' do
      expect {
        put :action, { device_action: missing_body }
      }.to change(DeviceAction, :count).by 0
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT #hive_queues' do
    let(:device) { Device.create(name: 'Test device') }
    let(:hive_queue_1) { HiveQueue.create(name: 'queue_one', description: 'First test queue') }
    let(:hive_queue_2) { HiveQueue.create(name: 'queue_two', description: 'Second test queue') }
    let(:device_with_queue) { Device.create(name: 'Test device', hive_queues: [hive_queue_1]) }

    it 'set a single hive queue for a device' do
      put :hive_queues, {
        device_id: device.id,
        hive_queues: [
          hive_queue_1.name
        ]
      }
      device.reload
      expect(device.hive_queues.length).to be 1
      expect(device.hive_queues[0]).to eq hive_queue_1
    end

    it 'removes a single hive queue from a device' do
      put :hive_queues, {
        device_id: device_with_queue.id,
        hive_queues: []
      }
      device_with_queue.reload
      expect(device_with_queue.hive_queues.length).to be 0
    end

    it 'removes hive queues from a device if nil' do
      put :hive_queues, {
        device_id: device_with_queue.id
      }
      device_with_queue.reload
      expect(device_with_queue.hive_queues.length).to be 0
    end

    it 'change hive queue for a device' do
      put :hive_queues, {
        device_id: device_with_queue.id,
        hive_queues: [
          hive_queue_2.name
        ]
      }
      device_with_queue.reload
      expect(device_with_queue.hive_queues.length).to be 1
      expect(device_with_queue.hive_queues[0]).to eq hive_queue_2
    end

    it 'sets two hive queues for a device' do
      put :hive_queues, {
        device_id: device.id,
        hive_queues: [
          hive_queue_1.name,
          hive_queue_2.name
        ]
      }
      device.reload
      expect(device.hive_queues.length).to be 2
      expect(device.hive_queues.map{ |q| q.name }).to match_array([hive_queue_1.name, hive_queue_2.name])
    end

    it 'adds an unknown queue to a device' do
      expect {
        put :hive_queues, {
          device_id: device.id,
          hive_queues: [
            'unknown queue'
          ]
        }
      }.to change(HiveQueue, :count).by 1
      device.reload
      expect(device.hive_queues.length).to be 1
      expect(device.hive_queues[0].name).to eq 'unknown queue'
    end

    it 'silently ignores a nil queue name' do
      expect {
        put :hive_queues, {
          device_id: device.id,
          hive_queues: [
            nil
          ]
        }
      }.to change(HiveQueue, :count).by 0
      device.reload
      expect(device.hive_queues.length).to be 0
    end

    it 'silently ignores an empty queue name' do
      expect {
        put :hive_queues, {
          device_id: device.id,
          hive_queues: [
            ''
          ]
        }
      }.to change(HiveQueue, :count).by 0
      device.reload
      expect(device.hive_queues.length).to be 0
    end
  end

  describe 'PUT #device_state' do
    let(:device) { Device.create(name: 'Test device') }
    let(:device2) { Device.create(name: 'Test device 2') }

    ['debug', 'info', 'warn', 'error', 'fatal'].each do |status|
      context "status is '#{status}'" do
        it 'adds an  log message' do
          expect {
            put :update_state, {
              device_state: {
                device_id: device.id,
                component: 'Test component',
                state: status,
                message: 'Test message'
              }
            }
          }.to change(DeviceState, :count).by 1
          expect(response).to have_http_status :ok
        end
      end
    end

    it 'fails to set an unknown state' do
      put :update_state, {
        device_state: {
          device_id: device.id,
          component: 'Test component',
          state: 'bad_status',
          message: 'Test message'
        }
      }
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'fails to set the state of an unknown device' do
      id = device.id
      device.destroy
      put :update_state, {
        device_state: {
          device_id: id,
          component: 'Test component',
          state: 'info',
          message: 'Test message'
        }
      }
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'clears the device state for a device' do
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      expect {
        put :update_state, {
          device_state: {
            device_id: device.id,
            state: 'clear'
          }
        }
      }.to change(DeviceState, :count).by -5
    end

    it 'only clears the state of the correct device' do
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device2, state: 'info')
      DeviceState.create(device: device2, state: 'info')
      expect {
        put :update_state, {
          device_state: {
            device_id: device.id,
            state: 'clear'
          }
        }
      }.to change(DeviceState, :count).by -3
    end

    it 'fails to clear state for all devices' do
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device, state: 'info')
      DeviceState.create(device: device2, state: 'info')
      DeviceState.create(device: device2, state: 'info')
      expect {
        put :update_state, {
          device_state: {
            state: 'clear'
          }
        }
      }.to change(DeviceState, :count).by 0
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context 'limit cleared states' do
      before(:each) do
        @debug =  DeviceState.create(device: device, state: 'debug')
        @info = DeviceState.create(device: device, state: 'info')
        @warn = DeviceState.create(device: device, state: 'warn')
        @error = DeviceState.create(device: device, state: 'error')
        @fatal = DeviceState.create(device: device, state: 'fatal')
      end

      it 'clears only debug messages' do
        put :update_state, { device_state: { device_id: device.id, state: 'clear', level: 'debug' } }
        expect(device.reload.device_states).to match_array([@info, @warn, @error, @fatal])
      end

      it 'clears only info and debug messages' do
        put :update_state, { device_state: { device_id: device.id, state: 'clear', level: 'info' } }
        expect(device.reload.device_states).to match_array([@warn, @error, @fatal])
      end

      it 'clears only warn, info and debug messages' do
        put :update_state, { device_state: { device_id: device.id, state: 'clear', level: 'warn' } }
        expect(device.reload.device_states).to match_array([@error, @fatal])
      end

      it 'clears only error, warn, info and debug messages' do
        put :update_state, { device_state: { device_id: device.id, state: 'clear', level: 'error' } }
        expect(device.reload.device_states).to match_array([@fatal])
      end

      it 'clears all messages' do
        put :update_state, { device_state: { device_id: device.id, state: 'clear', level: 'fatal' } }
        expect(device.reload.device_states).to match_array([])
      end

      it 'clears all messages with nil level' do
        put :update_state, { device_state: { device_id: device.id, state: 'clear', level: nil } }
        expect(device.reload.device_states).to match_array([])
      end
    end

    it 'clears messages for a component' do
      component_1 = DeviceState.create(device: device, component: 'one', state: 'info')
      component_2 = DeviceState.create(device: device, component: 'two', state: 'info')
      component_3 = DeviceState.create(device: device, component: 'three', state: 'info')
      put :update_state, { device_state: { device_id: device.id, state: 'clear', component: 'one' } }
      expect(device.reload.device_states).to match_array([component_2, component_3])
    end

    it 'clears all messages for a nil component' do
      component_1 = DeviceState.create(device: device, component: 'one', state: 'info')
      component_2 = DeviceState.create(device: device, component: 'two', state: 'info')
      component_3 = DeviceState.create(device: device, component: 'three', state: 'info')
      put :update_state, { device_state: { device_id: device.id, state: 'clear', component: nil } }
      expect(device.reload.device_states.count).to eq 0
    end

    it 'clears a message by state id' do
      state_one = DeviceState.create(device: device, state: 'info')
      state_two = DeviceState.create(device: device, state: 'info')
      state_three = DeviceState.create(device: device, state: 'info')

      put :update_state, { device_state: { state_ids: [ state_one.id ], state: 'clear' } }
      expect(device.reload.device_states).to match_array([state_two, state_three])
    end

    it 'clears multiple messages by state id' do
      state_one = DeviceState.create(device: device, state: 'info')
      state_two = DeviceState.create(device: device, state: 'info')
      state_three = DeviceState.create(device: device, state: 'info')

      put :update_state, { device_state: { state_ids: [ state_one.id, state_two.id ], state: 'clear' } }
      expect(device.reload.device_states).to_not include(state_one)
      expect(device.reload.device_states).to_not include(state_two)
      expect(device.reload.device_states).to match_array([state_three])
    end
  end
end
