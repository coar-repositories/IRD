require "rails_helper"

RSpec.describe "Home page", type: :system do
  before do
    driven_by :selenium, using: :headless_firefox, screen_size: [ 1400, 1400 ] # use :firefox (not headless) to see what's going on
  end

  it "enables me to view the home page" do
    visit "/"

    # fill_in "Name", :with => "My Widget"
    # click_button "Create Widget"

    expect(page).to have_text("This is the International Repositories Directory")
  end
end