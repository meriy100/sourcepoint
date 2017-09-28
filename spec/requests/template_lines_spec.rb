require 'rails_helper'

RSpec.describe "TemplateLines", type: :request do
  describe "GET /template_lines" do
    it "works! (now write some real specs)" do
      get template_lines_path
      expect(response).to have_http_status(200)
    end
  end
end
