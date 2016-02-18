require 'rails_helper'

RSpec.describe OperatingSystemsHelper, type: :helper do
  describe '#display_operating_system' do
    context 'passed an OperatingSystem instance' do
      let(:os) { OperatingSystem.new(name: 'Test OS', version: '99') }
      let(:os_no_version) { OperatingSystem.new(name: 'Test OS') }
      let(:os_no_name) { OperatingSystem.new(version: '88') }
      let(:os_null) { OperatingSystem.new }

      it 'displays the operating system with version' do
        expect(display_operating_system(os)).to eq 'Test OS 99'
      end

      it 'displays the operating system without version' do
        expect(display_operating_system(os_no_version)).to eq 'Test OS'
      end

      it 'displays the operating system without name' do
        expect(display_operating_system(os_no_name)).to eq '??OS?? 88'
      end

      it 'displays the operating system without name or version' do
        expect(display_operating_system(os_null)).to eq '??OS??'
      end
    end

    context 'passed a device' do
      let(:device) { Device.new }

      it 'displays the operating system with version' do
        device.set_os(name: 'Test OS', version: '99')
        expect(display_operating_system(device)).to eq 'Test OS 99'
      end

      it 'displays the operating system without version' do
        device.set_os(name: 'Test OS')
        expect(display_operating_system(device)).to eq 'Test OS'
      end

      it 'displays the operating system without name' do
        device.set_os(version: '88')
        expect(display_operating_system(device)).to eq '??OS?? 88'
      end

      it 'displays the operating system without name or version' do
        device.set_os()
        expect(display_operating_system(device)).to eq '??OS??'
      end

      it 'displays the (unset) operating system' do
        expect(display_operating_system(device)).to eq '??OS??'
      end
    end
  end
end
