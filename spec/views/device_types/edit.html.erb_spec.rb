require 'rails_helper'

RSpec.describe "device_types/edit", type: :view do
  before(:each) do
    @device_type = assign(:device_type, DeviceType.create!(
      :classification => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit device_type form" do
    render

    assert_select "form[action=?][method=?]", device_type_path(@device_type), "post" do

      assert_select "input#device_type_classification[name=?]", "device_type[classification]"

      assert_select "textarea#device_type_description[name=?]", "device_type[description]"
    end
  end
end
