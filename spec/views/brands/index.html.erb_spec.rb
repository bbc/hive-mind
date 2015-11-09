require 'rails_helper'

RSpec.describe "brands/index", type: :view do
  before(:each) do
    assign(:brands, [
      Brand.create!(
        :name => "Name",
        :code => "Code",
        :alternative => "Alternative"
      ),
      Brand.create!(
        :name => "Name",
        :code => "Code",
        :alternative => "Alternative"
      )
    ])
  end

  it "renders a list of brands" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Code".to_s, :count => 2
    assert_select "tr>td", :text => "Alternative".to_s, :count => 2
  end
end
