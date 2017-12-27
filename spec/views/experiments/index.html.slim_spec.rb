require 'rails_helper'

RSpec.describe "experiments/index", type: :view do
  before(:each) do
    assign(:experiments, [
      Experiment.create!(
        :file1 => "",
        :assignment => nil,
        :experiment_user => nil
      ),
      Experiment.create!(
        :file1 => "",
        :assignment => nil,
        :experiment_user => nil
      )
    ])
  end

  it "renders a list of experiments" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
