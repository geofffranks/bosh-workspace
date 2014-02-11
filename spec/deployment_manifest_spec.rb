describe Bosh::Manifests::DeploymentManifest do
  subject { Bosh::Manifests::DeploymentManifest.new manifest_file }
  let(:manifest_file) { get_tmp_file_path(manifest.to_yaml) }
  let(:name) { "foo" }
  let(:uuid) { "foo-bar-uuid" }
  let(:deployments) { [ "child-deployment.yml" ] }
  let(:templates) { ["path_to_bar", "path_to_baz"] }
  let(:releases) { [
    { "name" => "foo", "version" => "latest", "git" => "example.com/foo.git" }
  ] }
  let(:meta) { { "foo" => "bar" } }
  let(:manifest) { {
    "name" => name,
    "director_uuid" => uuid,
    "deployments" => deployments,
    "templates" => templates,
    "releases" => releases,
    "meta" => meta,
  } }

  context "validation" do
    let(:validation_manifest) { manifest.tap { |m| m.delete(missing) } }
    let(:manifest_file) { get_tmp_file_path(validation_manifest.to_yaml) }

    before do
      subject.validate
    end

    context "not a hash" do
      let(:validation_manifest) { "foo" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest should be a hash"]
      end
    end

    context "missing name" do
      let(:missing) { "name" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest should contain a name"]
      end
    end

    context "missing director_uuid" do
      let(:missing) { "director_uuid" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest should contain a director_uuid"]
      end
    end

    context "missing templates" do
      let(:missing) { "templates" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest should contain templates"]
      end
    end

    context "missing releases" do
      let(:missing) { "releases" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest should contain releases"]
      end
    end

    context "missing meta" do
      let(:missing) { "meta" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest should contain meta hash"]
      end
    end

    context "optional deployments" do
      let(:missing) { "deployments" }
      it { should be_valid }
    end

    context "invalid deployments" do
      let(:deployments) { "not-an-array" }
      let(:missing) { "none" }
      it "raises an error" do
        expect(subject.errors).to eq ["Manifest: deployments should be array"]
      end
    end
  end

  context "valid manifest" do
    it "has properties" do
      subject.validate
      expect(subject).to be_valid
      expect(subject.name).to eq name
      expect(subject.director_uuid).to eq uuid
      expect(subject.templates).to eq templates
      expect(subject.releases).to eq releases
      expect(subject.meta).to eq meta
    end
  end
end
