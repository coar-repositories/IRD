require 'rails_helper'

RSpec.describe "Errors", type: :request do
  describe "GET /not_found" do
    it "returns http success" do
      get "/errors/not_found"
      expect(response).to have_http_status(404)
    end
  end

  describe "GET /internal_server_error" do
    it "returns http success" do
      get "/errors/internal_server_error"
      expect(response).to have_http_status(500)
    end
  end

  describe "GET /forbidden" do
    it "returns http success" do
      get "/errors/forbidden"
      expect(response).to have_http_status(403)
    end
  end

end
