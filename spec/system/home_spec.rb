require "rails_helper"

RSpec.describe "Home page", type: :system do

  it "enables me to view the home page" do
    visit "/"

    # fill_in "Name", :with => "My Widget"
    # click_button "Create Widget"

    expect(page).to have_text("This is the International Repositories Directory")
  end
end