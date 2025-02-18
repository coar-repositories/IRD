require 'rails_helper'

RSpec.describe BrowserPolicy, type: :policy do
  subject { described_class }

  permissions :index? do
    it "denies access tp public if PREVENT_PUBLIC_ACCESS_TO_DATA is set" do
      expect(subject).not_to permit(nil) if ENV["PREVENT_PUBLIC_ACCESS_TO_DATA"] == "true"
    end
    it "grants access to public if PREVENT_PUBLIC_ACCESS_TO_DATA is not set" do
      expect(subject).to permit(nil) unless ENV["PREVENT_PUBLIC_ACCESS_TO_DATA"] == "true"
    end
  end
end