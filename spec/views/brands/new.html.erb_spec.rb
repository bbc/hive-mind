require 'rails_helper'

RSpec.describe "brands/new", type: :view do
  before(:each) do
    assign(:brand, Brand.new(
      :name => "MyString",
      :code => "MyString",
      :alternative => "MyString"
    ))
  end

  it "renders new brand form" do
    render

    assert_select "form[action=?][method=?]", brands_path, "post" do

      assert_select "input#brand_name[name=?]", "brand[name]"

      assert_select "input#brand_code[name=?]", "brand[code]"

      assert_select "input#brand_alternative[name=?]", "brand[alternative]"
    end
  end
end
