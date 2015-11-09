require 'rails_helper'

RSpec.describe "groups/new", type: :view do
  before(:each) do
    assign(:group, Group.new(
      :name => "MyString",
      :value => "MyString",
      :description => "MyText"
    ))
  end

  it "renders new group form" do
    render

    assert_select "form[action=?][method=?]", groups_path, "post" do

      assert_select "input#group_name[name=?]", "group[name]"

      assert_select "input#group_value[name=?]", "group[value]"

      assert_select "textarea#group_description[name=?]", "group[description]"
    end
  end
end
