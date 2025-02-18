require "rails_helper"

RSpec.describe "Admin screen", type: :system do
  fixtures :systems
  before do
    driven_by :selenium, using: :headless_firefox, screen_size: [ 1400, 1400 ] # use :firefox (not headless) to see what's going on
  end
  it "enables me to view the admin screen" do
    visit authenticate_as_url(email: users(:administrator).email)

    # visit user_root_url
    # expect(page).to have_selector("h1", text: "Dashboard for PW Admin")

    visit admin_url
    expect(page).to have_selector("h1", text: "Admin")
  end
end