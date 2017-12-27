require 'rails_helper'

RSpec.describe "experiment_users/show", type: :view do
  before(:each) do
    @experiment_user = assign(:experiment_user, ExperimentUser.create!(
      :name => "Name",
      :deleted_at => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
  end
end
