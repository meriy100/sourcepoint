require 'rails_helper'

RSpec.describe "experiment_users/edit", type: :view do
  before(:each) do
    @experiment_user = assign(:experiment_user, ExperimentUser.create!(
      :name => "MyString",
      :deleted_at => ""
    ))
  end

  it "renders the edit experiment_user form" do
    render

    assert_select "form[action=?][method=?]", experiment_user_path(@experiment_user), "post" do

      assert_select "input#experiment_user_name[name=?]", "experiment_user[name]"

      assert_select "input#experiment_user_deleted_at[name=?]", "experiment_user[deleted_at]"
    end
  end
end
