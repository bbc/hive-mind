require 'rails_helper'

RSpec.describe "device_types/show", type: :view do
  before(:each) do
    @device_type = assign(:device_type, DeviceType.create!(
      :classification => "Classification",
      :description => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Classification/)
    expect(rendered).to match(/MyText/)
  end
end
