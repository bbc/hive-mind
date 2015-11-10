require 'rails_helper'

RSpec.describe "device_types/new", type: :view do
  before(:each) do
    assign(:device_type, DeviceType.new(
      :classification => "MyString",
      :description => "MyText"
    ))
  end

  it "renders new device_type form" do
    render

    assert_select "form[action=?][method=?]", device_types_path, "post" do

      assert_select "input#device_type_classification[name=?]", "device_type[classification]"

      assert_select "textarea#device_type_description[name=?]", "device_type[description]"
    end
  end
end
