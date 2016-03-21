require 'rails_helper'

RSpec.describe HiveMindTv::ApiController, type: :controller do
  let(:tv_plugin) { HiveMindTv::Plugin.create }
  let(:tv) { Device.create(plugin: tv_plugin) }
  let(:non_tv) { Device.create }

  describe '#set_application' do
    it 'sets the application of a TV' do
      put :set_application, { device: { id: tv.id, application: 'Test app' } }
      tv.reload
      expect(tv.plugin.application).to eq 'Test app'
    end

    it 'fails to set the application of a device that is not a TV' do
      put :set_application, { device: { id: non_tv.id, application: 'Test app' } }
      expect(response).to have_http_status(:unprocessable_entity)

    end

    it 'fails to set the application of an unknown device' do
      put :set_application, { device: { id: 999, application: 'Test app' } }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns unprocessable entity status if id is missing' do
      put :set_application, { device: { application: 'Test app' } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
