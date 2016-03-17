require 'rails_helper'
require 'timecop'

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
      
      it "has a 'visible' status when the device has been seen in the last 90 seconds" do
        device.heartbeat
        expect(device.status).to eq :visible
      end
      
      it "has an unresponsive status when the device hasn't been seen in 90 seconds" do
        Timecop.freeze(Time.now - 91) do
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
      
      it "has a 'happy' status when the device has been seen in the last 90 seconds" do
        device.heartbeat
        expect(device.status).to eq :happy
      end
      
      it "has an 'unhappy' status when the device hasn't been seen in 90 seconds" do
        Timecop.freeze(Time.now - 91) do
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
end
