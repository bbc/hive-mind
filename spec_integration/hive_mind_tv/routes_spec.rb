require "rails_helper"

RSpec.describe HiveMindHive::ApiController, type: :routing do
  describe 'routing' do
    it 'routes to #application' do
      expect(put: '/api/plugin/tv/set_application').to route_to('hive_mind_tv/api#set_application', format: :json)
    end
  end
end
