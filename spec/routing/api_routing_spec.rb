require "rails_helper"

RSpec.describe Api::DevicesController, type: :routing do
  describe 'routing' do
    it "routes to #show in the devices controller" do
      expect(:get => "/api/devices/1").to route_to("devices#show", format: :json, id: "1")
    end

    it "routes to #index in the devices controller" do
      expect(:get => "/api/devices").to route_to("devices#index", format: :json)
    end

    it 'routes to #register' do
      expect(post: '/api/devices/register').to route_to('api/devices#register', format: :json)
    end

    it 'routes to #poll' do
      expect(put: '/api/devices/poll').to route_to('api/devices#poll', format: :json)
    end

    it 'routes to #action' do
      expect(put: 'api/devices/action').to route_to('api/devices#action', format: :json)
    end

    it 'routes to #hive_queues' do
      expect(put: 'api/devices/hive_queues').to route_to('api/devices#hive_queues', format: :json)
    end
  end
end
