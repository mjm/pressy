require 'spec_helper'

Push = Pressy::Action::Push

RSpec.describe Push do
  let(:changeset) { double(:changeset) }
  before { allow(Pressy::RemoteChangeset).to receive(:new) { changeset } }

  context "when the changeset has no changes" do
    subject { Push.new(local: [], server: []) }

    before do
      expect(changeset).to receive(:has_changes?) { false }
    end

    it "has no changes" do
      expect(subject).not_to have_changes
    end
  end

  context "when the changeset has changes" do
    subject { Push.new(local: [], server: []) }

    before do
      expect(changeset).to receive(:has_changes?) { true }
    end

    it "has changes" do
      expect(subject).to have_changes
    end
  end

  context "when there are no local or server posts" do
    subject { Push.new(local: [], server: []) }

    it "doesn't add any posts to the changeset" do
      expect(changeset).not_to receive(:add_local_post)
      expect(changeset).not_to receive(:add_server_post)
      subject.changeset
    end
  end

  context "when there are local posts" do
    let(:local_post) { make_rendered_post(path: "standard/foo.md", content: 'foo') }
    let(:parsed_local_post) { make_server_post }

    subject { Push.new(local: [local_post], server: []) }

    before do
      expect(Pressy::PostParser).to receive(:parse).with(format: 'standard', content: 'foo') { parsed_local_post }
    end

    it "adds the local post to the changeset" do
      expect(changeset).to receive(:add_local_post).with(local_post, parsed_local_post)
      expect(changeset).not_to receive(:add_server_post)
      subject.changeset
    end
  end

  context "when there are server posts" do
    let(:server_post) { make_server_post(id: 3) }

    subject { Push.new(local: [], server: [server_post]) }

    it "adds the server post to the changeset" do
      expect(changeset).not_to receive(:add_local_post)
      expect(changeset).to receive(:add_server_post).with(server_post)
      subject.changeset
    end
  end
end

def make_rendered_post(params = {})
  instance_double("Pressy::RenderedPost", params)
end

def make_server_post(params = {})
  instance_double("Pressy::Post", params)
end
