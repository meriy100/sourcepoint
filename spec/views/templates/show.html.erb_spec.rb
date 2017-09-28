require 'rails_helper'

RSpec.describe "templates/show", type: :view do
  before(:each) do
    @template = assign(:template, Template.create!(
      :file1 => "",
      :status => "Status",
      :user_id => 2,
      :encode_code => "Encode Code",
      :current_assignment_id => 3,
      :assignment_id => 4
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Encode Code/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
  end
end
