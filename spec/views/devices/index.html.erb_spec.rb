require 'rails_helper'

RSpec.describe "devices/index", type: :view do
  before(:each) do
    assign(:devices, [
      Device.create!(
        :name => "Name",
        :serial => "Serial",
        :asset_id => "Asset",
        :alternative => "Alternative",
        :model => nil
      ),
      Device.create!(
        :name => "Name",
        :serial => "Serial",
        :asset_id => "Asset",
        :alternative => "Alternative",
        :model => nil
      )
    ])
  end

  it "renders a list of devices" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Serial".to_s, :count => 2
    assert_select "tr>td", :text => "Asset".to_s, :count => 2
    assert_select "tr>td", :text => "Alternative".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
