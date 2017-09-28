require 'rails_helper'

RSpec.describe "template_lines/new", type: :view do
  before(:each) do
    assign(:template_line, TemplateLine.new(
      :template => nil,
      :number => 1,
      :deleted_line => false
    ))
  end

  it "renders new template_line form" do
    render

    assert_select "form[action=?][method=?]", template_lines_path, "post" do

      assert_select "input#template_line_template_id[name=?]", "template_line[template_id]"

      assert_select "input#template_line_number[name=?]", "template_line[number]"

      assert_select "input#template_line_deleted_line[name=?]", "template_line[deleted_line]"
    end
  end
end
