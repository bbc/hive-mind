require 'rails_helper'

RSpec.describe "brands/edit", type: :view do
  before(:each) do
    @brand = assign(:brand, Brand.create!(
      :name => "MyString",
      :code => "MyString",
      :alternative => "MyString"
    ))
  end

  it "renders the edit brand form" do
    render

    assert_select "form[action=?][method=?]", brand_path(@brand), "post" do

      assert_select "input#brand_name[name=?]", "brand[name]"

      assert_select "input#brand_code[name=?]", "brand[code]"

      assert_select "input#brand_alternative[name=?]", "brand[alternative]"
    end
  end
end
