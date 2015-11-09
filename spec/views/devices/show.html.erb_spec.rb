require 'rails_helper'

RSpec.describe "devices/show", type: :view do
  before(:each) do
    @device = assign(:device, Device.create!(
      :name => "Name",
      :serial => "Serial",
      :asset_id => "Asset",
      :alternative => "Alternative",
      :model => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Serial/)
    expect(rendered).to match(/Asset/)
    expect(rendered).to match(/Alternative/)
    expect(rendered).to match(//)
  end
end
