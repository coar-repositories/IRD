require 'rails_helper'

RSpec.describe "Countries", type: :request do
  describe "GET /index" do
    fixtures :countries
    it "renders the countries page" do
      passwordless_sign_in(users(:administrator))
      get countries_url
      expect(response).to render_template(:index)
      expect(response).to be_successful
    end
  end
end
