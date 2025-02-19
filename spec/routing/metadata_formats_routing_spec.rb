require "rails_helper"

RSpec.describe MetadataFormatsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/metadata_formats").to route_to("metadata_formats#index")
    end

    it "routes to #new" do
      expect(get: "/metadata_formats/new").to route_to("metadata_formats#new")
    end

    it "routes to #show" do
      expect(get: "/metadata_formats/1").to route_to("metadata_formats#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/metadata_formats/1/edit").to route_to("metadata_formats#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/metadata_formats").to route_to("metadata_formats#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/metadata_formats/1").to route_to("metadata_formats#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/metadata_formats/1").to route_to("metadata_formats#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/metadata_formats/1").to route_to("metadata_formats#destroy", id: "1")
    end
  end
end
