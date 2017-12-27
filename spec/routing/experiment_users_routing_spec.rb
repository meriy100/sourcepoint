require "rails_helper"

RSpec.describe ExperimentUsersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/experiment_users").to route_to("experiment_users#index")
    end

    it "routes to #new" do
      expect(:get => "/experiment_users/new").to route_to("experiment_users#new")
    end

    it "routes to #show" do
      expect(:get => "/experiment_users/1").to route_to("experiment_users#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/experiment_users/1/edit").to route_to("experiment_users#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/experiment_users").to route_to("experiment_users#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/experiment_users/1").to route_to("experiment_users#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/experiment_users/1").to route_to("experiment_users#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/experiment_users/1").to route_to("experiment_users#destroy", :id => "1")
    end

  end
end
