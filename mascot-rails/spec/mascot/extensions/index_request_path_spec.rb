require "spec_helper"

describe Mascot::Extensions::IndexRequestPath do
  subject { Mascot::Extensions::IndexRequestPath.new }
  let(:resources) { Mascot::Sitemap.new(root: "spec/pages").resources.glob("**/index*") }
  let(:resource) { resources.first }

  context "#process_resources" do
    before { subject.process_resources(resources) }
    it "changes /index.html request_path to /" do
      # require "pry" ; binding.pry
      expect(resource.request_path).to eql("/")
    end
  end
end
