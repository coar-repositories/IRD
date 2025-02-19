require 'rails_helper'

RSpec.describe "metadata_formats/new", type: :view do
  before(:each) do
    assign(:metadata_format, MetadataFormat.new(
      name: "MyString",
      version: "MyString",
      canonical_schema: "MyString",
      matchers: "MyString",
      match_order: 1.5
    ))
  end

  it "renders new metadata_format form" do
    render

    assert_select "form[action=?][method=?]", metadata_formats_path, "post" do

      assert_select "input[name=?]", "metadata_format[name]"

      assert_select "input[name=?]", "metadata_format[version]"

      assert_select "input[name=?]", "metadata_format[canonical_schema]"

      assert_select "input[name=?]", "metadata_format[matchers]"

      assert_select "input[name=?]", "metadata_format[match_order]"
    end
  end
end
