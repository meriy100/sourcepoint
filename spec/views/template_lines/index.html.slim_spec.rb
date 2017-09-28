require 'rails_helper'

RSpec.describe "template_lines/index", type: :view do
  before(:each) do
    assign(:template_lines, [
      TemplateLine.create!(
        :template => nil,
        :number => 2,
        :deleted_line => false
      ),
      TemplateLine.create!(
        :template => nil,
        :number => 2,
        :deleted_line => false
      )
    ])
  end

  it "renders a list of template_lines" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
