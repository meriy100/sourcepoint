require "rails_helper"

RSpec.describe TemplateLinesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/template_lines").to route_to("template_lines#index")
    end

    it "routes to #new" do
      expect(:get => "/template_lines/new").to route_to("template_lines#new")
    end

    it "routes to #show" do
      expect(:get => "/template_lines/1").to route_to("template_lines#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/template_lines/1/edit").to route_to("template_lines#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/template_lines").to route_to("template_lines#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/template_lines/1").to route_to("template_lines#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/template_lines/1").to route_to("template_lines#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/template_lines/1").to route_to("template_lines#destroy", :id => "1")
    end

  end
end
