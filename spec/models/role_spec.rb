require 'rails_helper'

RSpec.describe Role, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context "on creation" do
    it "creates a valid ID from the name" do
      role = Role.create!(
        :name => "Test Role",
      )
      expect(role.id).to eq('test-role')
    end
  end
end
