require 'rails_helper'
require 'timecop'
require 'logger'

RSpec.describe Device, type: :model do
  describe '#status' do
    it 'returns a symbol representing status' do
      device = Device.new(name: 'Blah')
      expect(device.status).to be_a Symbol
    end
    
    context "not connected to a hive" do
      let( :device ) { Device.new }
      
      it "has a default 'unknown' status" do
        expect(device.status).to eq :unknown
      end
      
      it "has a 'visible' status when the device has been seen in the last 180 seconds" do
        device.heartbeat
        expect(device.status).to eq :visible
      end
      
      it "has an unresponsive status when the device hasn't been seen in 180 seconds" do
        Timecop.freeze(Time.now - 181) do
          device.heartbeat
        end
        expect(device.status).to eq :unresponsive
      end
      
      it "has an 'unknown' status when the device hasn't been seen in 600 seconds" do
        Timecop.freeze(Time.now - 601) do
          device.heartbeat
        end
        expect(device.status).to eq :unknown
      end
    end
    
    context "connected to a hive" do
      let( :device ) do
        device = Device.new
        allow(device).to receive(:in_a_hive?).and_return(true)
        device
      end
      
      it "has a default 'unknown' status" do
        expect(device.status).to eq :unknown
      end
      
      it "has a 'happy' status when the device has been seen in the last 180 seconds" do
        device.heartbeat
        expect(device.status).to eq :happy
      end
      
      it "has an 'unhappy' status when the device hasn't been seen in 180 seconds" do
        Timecop.freeze(Time.now - 181) do
          device.heartbeat
        end
        expect(device.status).to eq :unhappy
      end
      
      it "has an 'dead' status when the device hasn't been seen in 600 seconds" do
        Timecop.freeze(Time.now - 601) do
          device.heartbeat
        end
        expect(device.status).to eq :dead
      end
    end
  end

  describe '#log_state_level' do
    let(:device) { Device.create }

    context 'device is visible' do
      before(:each) do
        device.heartbeat
      end

      it 'reports info level by default' do
        expect(device.log_state_level).to eq Logger::Severity::INFO
      end

      it 'reports info level with only debug logs' do
        DeviceState.create(state: 'debug', device: device)
        expect(device.log_state_level).to eq Logger::Severity::INFO
      end

      it 'reports info level with debug and info logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        expect(device.log_state_level).to eq Logger::Severity::INFO
      end

      it 'reports warn level with debug, info and warn logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        expect(device.log_state_level).to eq Logger::Severity::WARN
      end

      it 'reports error level with debug, info, warn and error logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports fatal level with debug, info, warn, error and fatal logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        DeviceState.create(state: 'fatal', device: device)
        expect(device.log_state_level).to eq Logger::Severity::FATAL
      end
    end

    context 'device has been unresponsive for between 180 and 600 seconds' do
      before(:each) do
        Timecop.freeze(Time.now - 181) do
          device.heartbeat
        end
      end

      it 'reports info level by default' do
        expect(device.log_state_level).to eq Logger::Severity::WARN
      end

      it 'reports info level with only debug logs' do
        DeviceState.create(state: 'debug', device: device)
        expect(device.log_state_level).to eq Logger::Severity::WARN
      end

      it 'reports info level with debug and info logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        expect(device.log_state_level).to eq Logger::Severity::WARN
      end

      it 'reports warn level with debug, info and warn logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        expect(device.log_state_level).to eq Logger::Severity::WARN
      end

      it 'reports error level with debug, info, warn and error logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports fatal level with debug, info, warn, error and fatal logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        DeviceState.create(state: 'fatal', device: device)
        expect(device.log_state_level).to eq Logger::Severity::FATAL
      end
    end

    context 'device has been unresponsive for over 600 seconds' do
      before(:each) do
        Timecop.freeze(Time.now - 601) do
          device.heartbeat
        end
      end

      it 'reports info level by default' do
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports info level with only debug logs' do
        DeviceState.create(state: 'debug', device: device)
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports info level with debug and info logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports warn level with debug, info and warn logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports error level with debug, info, warn and error logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        expect(device.log_state_level).to eq Logger::Severity::ERROR
      end

      it 'reports fatal level with debug, info, warn, error and fatal logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        DeviceState.create(state: 'fatal', device: device)
        expect(device.log_state_level).to eq Logger::Severity::FATAL
      end
    end
  end

  describe '#log_state_label' do
    let(:device) { Device.create }

    context 'device is visible' do
      before(:each) do
        device.heartbeat
      end

      it 'reports info label by default' do
        expect(device.log_state_label).to eq 'info'
      end

      it 'reports info label with only debug logs' do
        DeviceState.create(state: 'debug', device: device)
        expect(device.log_state_label).to eq 'info'
      end

      it 'reports info label with debug and info logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        expect(device.log_state_label).to eq 'info'
      end

      it 'reports warn label with debug, info and warn logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        expect(device.log_state_label).to eq 'warn'
      end

      it 'reports error label with debug, info, warn and error logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports fatal label with debug, info, warn, error and fatal logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        DeviceState.create(state: 'fatal', device: device)
        expect(device.log_state_label).to eq 'fatal'
      end
    end

    context 'device has been unresponsive for between 180 and 600 seconds' do
      before(:each) do
        Timecop.freeze(Time.now - 181) do
          device.heartbeat
        end
      end

      it 'reports warn label by default' do
        expect(device.log_state_label).to eq 'warn'
      end

      it 'reports warn label with only debug logs' do
        DeviceState.create(state: 'debug', device: device)
        expect(device.log_state_label).to eq 'warn'
      end

      it 'reports warn label with debug and info logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        expect(device.log_state_label).to eq 'warn'
      end

      it 'reports warn label with debug, info and warn logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        expect(device.log_state_label).to eq 'warn'
      end

      it 'reports error label with debug, info, warn and error logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports fatal label with debug, info, warn, error and fatal logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        DeviceState.create(state: 'fatal', device: device)
        expect(device.log_state_label).to eq 'fatal'
      end
    end

    context 'device has been unresponsive for over 600 seconds' do
      before(:each) do
        Timecop.freeze(Time.now - 601) do
          device.heartbeat
        end
      end

      it 'reports error label by default' do
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports error label with only debug logs' do
        DeviceState.create(state: 'debug', device: device)
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports error label with debug and info logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports error label with debug, info and warn logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports error label with debug, info, warn and error logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        expect(device.log_state_label).to eq 'error'
      end

      it 'reports fatal label with debug, info, warn, error and fatal logs' do
        DeviceState.create(state: 'debug', device: device)
        DeviceState.create(state: 'info', device: device)
        DeviceState.create(state: 'warn', device: device)
        DeviceState.create(state: 'error', device: device)
        DeviceState.create(state: 'fatal', device: device)
        expect(device.log_state_label).to eq 'fatal'
      end
    end
  end
end
