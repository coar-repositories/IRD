require 'rails_helper'

RSpec.describe "metadata_formats/index", type: :view do
  before(:each) do
    assign(:metadata_formats, [
      MetadataFormat.create!(
        name: "Name",
        version: "Version",
        canonical_schema: "Canonical Schema",
        matchers: "Matchers",
        match_order: 2.5
      ),
      MetadataFormat.create!(
        name: "Name",
        version: "Version",
        canonical_schema: "Canonical Schema",
        matchers: "Matchers",
        match_order: 2.5
      )
    ])
  end

  it "renders a list of metadata_formats" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Version".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Canonical Schema".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Matchers".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.5.to_s), count: 2
  end
end
