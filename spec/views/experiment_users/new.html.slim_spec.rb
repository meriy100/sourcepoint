require 'rails_helper'

RSpec.describe "experiment_users/new", type: :view do
  before(:each) do
    assign(:experiment_user, ExperimentUser.new(
      :name => "MyString",
      :deleted_at => ""
    ))
  end

  it "renders new experiment_user form" do
    render

    assert_select "form[action=?][method=?]", experiment_users_path, "post" do

      assert_select "input#experiment_user_name[name=?]", "experiment_user[name]"

      assert_select "input#experiment_user_deleted_at[name=?]", "experiment_user[deleted_at]"
    end
  end
end
