require 'rails_helper'

RSpec.describe "experiment_users/index", type: :view do
  before(:each) do
    assign(:experiment_users, [
      ExperimentUser.create!(
        :name => "Name",
        :deleted_at => ""
      ),
      ExperimentUser.create!(
        :name => "Name",
        :deleted_at => ""
      )
    ])
  end

  it "renders a list of experiment_users" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
