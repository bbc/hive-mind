require "rails_helper"

RSpec.describe HiveMindHive::ApiController, type: :routing do
  describe 'routing' do
    it 'routes to #connect' do
      expect(put: '/api/plugin/hive/connect').to route_to('hive_mind_hive/api#connect', format: :json)
    end

    it 'routes to #disconnect' do
      expect(put: '/api/plugin/hive/disconnect').to route_to('hive_mind_hive/api#disconnect', format: :json)
    end
  end
end
