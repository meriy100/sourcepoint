require 'rails_helper'

RSpec.describe "templates/new", type: :view do
  before(:each) do
    assign(:template, Template.new(
      :file1 => "",
      :status => "MyString",
      :user_id => 1,
      :encode_code => "MyString",
      :current_assignment_id => 1,
      :assignment_id => 1
    ))
  end

  it "renders new template form" do
    render

    assert_select "form[action=?][method=?]", templates_path, "post" do

      assert_select "input#template_file1[name=?]", "template[file1]"

      assert_select "input#template_status[name=?]", "template[status]"

      assert_select "input#template_user_id[name=?]", "template[user_id]"

      assert_select "input#template_encode_code[name=?]", "template[encode_code]"

      assert_select "input#template_current_assignment_id[name=?]", "template[current_assignment_id]"

      assert_select "input#template_assignment_id[name=?]", "template[assignment_id]"
    end
  end
end
