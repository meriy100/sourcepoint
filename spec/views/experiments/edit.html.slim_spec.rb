require 'rails_helper'

RSpec.describe "experiments/edit", type: :view do
  before(:each) do
    @experiment = assign(:experiment, Experiment.create!(
      :file1 => "",
      :assignment => nil,
      :experiment_user => nil
    ))
  end

  it "renders the edit experiment form" do
    render

    assert_select "form[action=?][method=?]", experiment_path(@experiment), "post" do

      assert_select "input#experiment_file1[name=?]", "experiment[file1]"

      assert_select "input#experiment_assignment_id[name=?]", "experiment[assignment_id]"

      assert_select "input#experiment_experiment_user_id[name=?]", "experiment[experiment_user_id]"
    end
  end
end
