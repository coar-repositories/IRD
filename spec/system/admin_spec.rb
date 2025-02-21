require "rails_helper"

RSpec.describe "Admin screen", type: :system do

  it "enables me to view the admin screen" do
    visit authenticate_as_url(email: users(:administrator).email)

    # visit user_root_url
    # expect(page).to have_selector("h1", text: "Dashboard for PW Admin")

    visit admin_url
    expect(page).to have_selector("h1", text: "Admin")
  end
end