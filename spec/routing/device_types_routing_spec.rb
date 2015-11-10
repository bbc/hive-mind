require "rails_helper"

RSpec.describe DeviceTypesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/device_types").to route_to("device_types#index")
    end

    it "routes to #new" do
      expect(:get => "/device_types/new").to route_to("device_types#new")
    end

    it "routes to #show" do
      expect(:get => "/device_types/1").to route_to("device_types#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/device_types/1/edit").to route_to("device_types#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/device_types").to route_to("device_types#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/device_types/1").to route_to("device_types#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/device_types/1").to route_to("device_types#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/device_types/1").to route_to("device_types#destroy", :id => "1")
    end

  end
end
