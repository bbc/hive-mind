require 'rails_helper'

RSpec.describe "devices/new", type: :view do
  before(:each) do
    assign(:device, Device.new(
      :name => "MyString",
      :serial => "MyString",
      :asset_id => "MyString",
      :alternative => "MyString",
      :model => nil
    ))
  end

  it "renders new device form" do
    render

    assert_select "form[action=?][method=?]", devices_path, "post" do

      assert_select "input#device_name[name=?]", "device[name]"

      assert_select "input#device_serial[name=?]", "device[serial]"

      assert_select "input#device_asset_id[name=?]", "device[asset_id]"

      assert_select "input#device_alternative[name=?]", "device[alternative]"

      assert_select "input#device_model_id[name=?]", "device[model_id]"
    end
  end
end
