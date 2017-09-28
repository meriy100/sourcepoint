require 'rails_helper'

RSpec.describe "template_lines/show", type: :view do
  before(:each) do
    @template_line = assign(:template_line, TemplateLine.create!(
      :template => nil,
      :number => 2,
      :deleted_line => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/false/)
  end
end
