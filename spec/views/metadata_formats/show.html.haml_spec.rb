require 'rails_helper'

RSpec.describe "metadata_formats/show", type: :view do
  before(:each) do
    assign(:metadata_format, MetadataFormat.create!(
      name: "Name",
      version: "Version",
      canonical_schema: "Canonical Schema",
      matchers: "Matchers",
      match_order: 2.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Version/)
    expect(rendered).to match(/Canonical Schema/)
    expect(rendered).to match(/Matchers/)
    expect(rendered).to match(/2.5/)
  end
end
