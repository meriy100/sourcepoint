require 'rails_helper'

RSpec.describe "templates/index", type: :view do
  before(:each) do
    assign(:templates, [
      Template.create!(
        :file1 => "",
        :status => "Status",
        :user_id => 2,
        :encode_code => "Encode Code",
        :current_assignment_id => 3,
        :assignment_id => 4
      ),
      Template.create!(
        :file1 => "",
        :status => "Status",
        :user_id => 2,
        :encode_code => "Encode Code",
        :current_assignment_id => 3,
        :assignment_id => 4
      )
    ])
  end

  it "renders a list of templates" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Encode Code".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end
