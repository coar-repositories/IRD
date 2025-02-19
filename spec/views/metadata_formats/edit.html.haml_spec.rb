require 'rails_helper'

RSpec.describe "metadata_formats/edit", type: :view do
  let(:metadata_format) {
    MetadataFormat.create!(
      name: "MyString",
      version: "MyString",
      canonical_schema: "MyString",
      matchers: "MyString",
      match_order: 1.5
    )
  }

  before(:each) do
    assign(:metadata_format, metadata_format)
  end

  it "renders the edit metadata_format form" do
    render

    assert_select "form[action=?][method=?]", metadata_format_path(metadata_format), "post" do

      assert_select "input[name=?]", "metadata_format[name]"

      assert_select "input[name=?]", "metadata_format[version]"

      assert_select "input[name=?]", "metadata_format[canonical_schema]"

      assert_select "input[name=?]", "metadata_format[matchers]"

      assert_select "input[name=?]", "metadata_format[match_order]"
    end
  end
end
