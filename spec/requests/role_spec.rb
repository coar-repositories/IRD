require 'rails_helper'

RSpec.describe "Roles", type: :request do
  describe "GET /index" do
    it "renders the roles page" do
      passwordless_sign_in(users(:administrator))
      get roles_url
      expect(response).to render_template(:index)
      expect(response).to be_successful
    end
  end
end
