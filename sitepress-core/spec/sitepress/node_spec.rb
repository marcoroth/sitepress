require "spec_helper"

context Sitepress::Node do
  let(:asset) { Sitepress::Asset.new(path: "/") }
  let(:root) do
    Sitepress::Node.new do |root|
      root.formats.add(format: :html, asset: asset)
      root.build_child("app") do |app|
        app.formats.add(format: :html, asset: asset)
        app.build_child("is") do |is|
          is.formats.add(format: :html, asset: asset)
          is.build_child("good").formats.add(format: :html, asset: asset)
          is.build_child("bad") do |bad|
            bad.formats.add(format: :html, asset: asset)
            bad.build_child("really").formats.add(format: :html, asset: asset)
          end
        end
        app.build_child("boo") do |boo|
          boo.formats.add(format: :html, asset: asset)
          boo.build_child("radly").formats.add(format: :html, asset: asset)
        end
      end
    end
  end
  let(:routes) { %w[
      /index.html
      /app.html
      /app/is.html
      /app/is/good.html
      /app/is/bad.html
      /app/is/bad/really.html
      /app/boo.html
      /app/boo/radly.html] }
  subject { root.get(path).node }
  it "is_root" do
    expect(root).to be_root
  end
  it "is_leaf" do
    expect(root.get("/app/boo/radly.html").node).to be_leaf
  end
  context "/app/is/bad.html" do
    let(:path) { "/app/is/bad.html" }
    it { should have_parents(%w[/app/is.html /app.html /.html]) }
    it { should have_siblings(%w[/app/is/good.html]) }
    it { should have_children(%w[/app/is/bad/really.html]) }
  end
  context "/app.html" do
    let(:path) { "/app.html" }
    it { should have_parents(%w[/.html]) }
    it { should have_siblings([]) }
    it { should have_children(%w[/app/is.html /app/boo.html]) }
  end
  context "/a/b/c.html" do
    let(:routes) { %w[
        /a.html
        /a/b.html
        /a/1.html
        /a/b/c.html] }
    let(:root) do
      Sitepress::Node.new do |root|
        root.build_child("a") do |a|
          a.formats.add(format: :html, asset: asset)
          a.build_child("1").formats.add(format: :html, asset: asset)
          a.build_child("b") do |b|
            b.formats.add(format: :html, asset: asset)
            b.build_child("c").formats.add(format: :html, asset: asset)
          end
        end
      end
    end
    let(:path) { "/a/b.html" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(["/a/b.html"])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.flatten.map(&:request_path)).to match_array(routes)
      end
    end
    it { should have_parents(["/a.html"]) }
    it { should have_siblings(%w[/a/1.html]) }
    it { should have_children(%w[/a/b/c.html]) }
    context "remove c.html" do
      before { subject.get("c.html").node.remove }
      it { should have_children([]) }
    end
    context "remove /a/b.html" do
      before { subject.remove }
      it { should have_parents(["/a.html"]) }
      it { should have_siblings(%w[/a/1.html]) }
      it { should have_children(%w[/a/b/c.html]) }
      it "does not have resource" do
        subject.formats.clear
      end
      it "removes route" do
        expect(root.flatten.map(&:request_path)).to match_array(routes - ["/a/b.html"])
      end
    end
  end
  context "/a/b/c" do
    let(:routes) { %w[
        /a
        /a/b
        /a/1
        /a/b/c] }
    let(:root) do
      Sitepress::Node.new do |root|
        root.build_child("a") do |a|
          a.formats.add(asset: asset)
          a.build_child("1").formats.add(asset: asset)
          a.build_child("b") do |b|
            b.formats.add(asset: asset)
            b.build_child("c").formats.add(asset: asset)
          end
        end
      end
    end
    let(:path) { "/a/b" }
    it "has resource" do
      expect(subject.formats.map(&:request_path)).to eql(["/a/b"])
    end
    context "enumerable" do
      it "iterates through resources" do
        expect(root.flatten.map(&:request_path)).to match_array(routes)
      end
    end
    it { should have_parents(["/a"]) }
    it { should have_siblings(%w[/a/1]) }
    it { should have_children(%w[/a/b/c]) }
    context "remove c" do
      before { subject.get("c").node.remove }
      it { should have_children([]) }
    end
    context "remove /a/b" do
      before { subject.remove }
      it { should have_parents(["/a"]) }
      it { should have_siblings(%w[/a/1]) }
      it { should have_children(%w[/a/b/c]) }
      it "does not have resource" do
        subject.formats.clear
      end
      it "removes route" do
        expect(root.flatten.map(&:request_path)).to match_array(routes - ["/a/b"])
      end
    end
  end
end
