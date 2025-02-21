require 'rails_helper'

RSpec.describe SystemsController, type: :request do
  describe "GET /systems/" do
    it "does not render the systems index page for public users, but redirects to error page" do
      passwordless_sign_out
      get systems_url
      expect(response).not_to be_successful
      expect(response).to redirect_to(error_403_url)
    end
  end

  describe "GET /systems/[:id]/edit" do
    it "does not render a system edit page for public user, but redirects to error page" do
      passwordless_sign_out
      get edit_system_url(systems(:zenodo).id)
      expect(response).not_to be_successful
      expect(response).to redirect_to(error_403_url)
    end

    it "renders a system edit page for users with role :superuser or :administrator" do
      passwordless_sign_in(users(:superuser))
      get edit_system_url(systems(:zenodo).id)
      expect(response).to render_template(:edit)
      expect(response).to be_successful
    end
  end
end
