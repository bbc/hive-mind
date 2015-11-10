require 'rails_helper'

RSpec.describe "DeviceTypes", type: :request do
  describe "GET /device_types" do
    it "works! (now write some real specs)" do
      get device_types_path
      expect(response).to have_http_status(200)
    end
  end
end
