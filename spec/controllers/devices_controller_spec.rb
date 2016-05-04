require 'rails_helper'

RSpec.describe DevicesController, type: :controller do

  let(:valid_attributes) {
    {
      name: 'Device 1'
    }
  }

  #let(:invalid_attributes) {
  #  skip("Add a hash of attributes invalid for your model")
  #}

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DevicesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all devices as @devices grouped by type" do
      device = Device.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:devices)).to eq(nil => [device])
    end
  end

  describe "GET #show" do
    it "assigns the requested device as @device" do
      device = Device.create! valid_attributes
      get :show, {:id => device.to_param}, valid_session
      expect(assigns(:device)).to eq(device)
    end

    it "returns a simple view" do
      device = Device.create! valid_attributes
      get :show, {id: device.to_param, format: :json, view: 'simple'}, valid_session
      expect(assigns(:device).keys).to match_array([:id, :name, :model, :brand, :device_type])
    end
  end

  #describe "GET #new" do
  #  it "assigns a new device as @device" do
  #    get :new, {}, valid_session
  #    expect(assigns(:device)).to be_a_new(Device)
  #  end
  #end

  #describe "GET #edit" do
  #  it "assigns the requested device as @device" do
  #    device = Device.create! valid_attributes
  #    get :edit, {:id => device.to_param}, valid_session
  #    expect(assigns(:device)).to eq(device)
  #  end
  #end

  #describe "POST #create" do
  #  context "with valid params" do
  #    it "creates a new Device" do
  #      expect {
  #        post :create, {:device => valid_attributes}, valid_session
  #      }.to change(Device, :count).by(1)
  #    end

  #    it "assigns a newly created device as @device" do
  #      post :create, {:device => valid_attributes}, valid_session
  #      expect(assigns(:device)).to be_a(Device)
  #      expect(assigns(:device)).to be_persisted
  #    end

  #    it "redirects to the created device" do
  #      post :create, {:device => valid_attributes}, valid_session
  #      expect(response).to redirect_to(Device.last)
  #    end
  #  end

  #  context "with invalid params" do
  #    it "assigns a newly created but unsaved device as @device" do
  #      post :create, {:device => invalid_attributes}, valid_session
  #      expect(assigns(:device)).to be_a_new(Device)
  #    end

  #    it "re-renders the 'new' template" do
  #      post :create, {:device => invalid_attributes}, valid_session
  #      expect(response).to render_template("new")
  #    end
  #  end
  #end

  #describe "PUT #update" do
  #  context "with valid params" do
  #    let(:new_attributes) {
  #      skip("Add a hash of attributes valid for your model")
  #    }

  #    it "updates the requested device" do
  #      device = Device.create! valid_attributes
  #      put :update, {:id => device.to_param, :device => new_attributes}, valid_session
  #      device.reload
  #      skip("Add assertions for updated state")
  #    end

  #    it "assigns the requested device as @device" do
  #      device = Device.create! valid_attributes
  #      put :update, {:id => device.to_param, :device => valid_attributes}, valid_session
  #      expect(assigns(:device)).to eq(device)
  #    end

  #    it "redirects to the device" do
  #      device = Device.create! valid_attributes
  #      put :update, {:id => device.to_param, :device => valid_attributes}, valid_session
  #      expect(response).to redirect_to(device)
  #    end
  #  end

  #  context "with invalid params" do
  #    it "assigns the device as @device" do
  #      device = Device.create! valid_attributes
  #      put :update, {:id => device.to_param, :device => invalid_attributes}, valid_session
  #      expect(assigns(:device)).to eq(device)
  #    end

  #    it "re-renders the 'edit' template" do
  #      device = Device.create! valid_attributes
  #      put :update, {:id => device.to_param, :device => invalid_attributes}, valid_session
  #      expect(response).to render_template("edit")
  #    end
  #  end
  #end

  describe "DELETE #destroy" do
    it "destroys the requested device" do
      device = Device.create! valid_attributes
      expect {
        delete :destroy, {:id => device.to_param}, valid_session
      }.to change(Device, :count).by(-1)
    end

    it "redirects to the devices list" do
      device = Device.create! valid_attributes
      delete :destroy, {:id => device.to_param}, valid_session
      expect(response).to redirect_to(devices_url)
    end
  end

end
