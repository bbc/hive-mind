require 'rails_helper'
require 'logger'

RSpec.describe DeviceState, type: :model do
  let (:device) { Device.create }

  describe '#create' do
    it 'translates debug state to Logger::Severity::DEBUG' do
      DeviceState.create(state: 'debug', device: device)
      expect(DeviceState.last.state).to eq Logger::Severity::DEBUG
    end

    it 'translates info state to Logger::Severity::INFO' do
      DeviceState.create(state: 'info', device: device)
      expect(DeviceState.last.state).to eq Logger::Severity::INFO
    end

    it 'translates debug state to Logger::Severity::WARN' do
      DeviceState.create(state: 'warn', device: device)
      expect(DeviceState.last.state).to eq Logger::Severity::WARN
    end

    it 'translates error state to Logger::Severity::ERROR' do
      DeviceState.create(state: 'error', device: device)
      expect(DeviceState.last.state).to eq Logger::Severity::ERROR
    end

    it 'translates fatal state to Logger::Severity::FATAL' do
      DeviceState.create(state: 'fatal', device: device)
      expect(DeviceState.last.state).to eq Logger::Severity::FATAL
    end

    it 'fails with an unknown state' do
      expect{DeviceState.create(state: 'badstate', device: device)}.to change(DeviceState, :count).by 0
    end
  end
end
