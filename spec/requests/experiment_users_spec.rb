require 'rails_helper'

RSpec.describe "ExperimentUsers", type: :request do
  describe "GET /experiment_users" do
    it "works! (now write some real specs)" do
      get experiment_users_path
      expect(response).to have_http_status(200)
    end
  end
end
