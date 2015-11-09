require 'rails_helper'

RSpec.describe "models/edit", type: :view do
  before(:each) do
    @model = assign(:model, Model.create!(
      :name => "MyString",
      :code => "MyString",
      :alternative => "MyString",
      :brand => nil
    ))
  end

  it "renders the edit model form" do
    render

    assert_select "form[action=?][method=?]", model_path(@model), "post" do

      assert_select "input#model_name[name=?]", "model[name]"

      assert_select "input#model_code[name=?]", "model[code]"

      assert_select "input#model_alternative[name=?]", "model[alternative]"

      assert_select "input#model_brand_id[name=?]", "model[brand_id]"
    end
  end
end
