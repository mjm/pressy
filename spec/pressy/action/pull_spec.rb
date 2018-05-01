require 'spec_helper'

Pull = Pressy::Action::Pull

RSpec.describe Pressy::Action::Pull do
  let(:changeset) { double(:changeset) }
  before { allow(Pressy::LocalChangeset).to receive(:new) { changeset } }

  context "when the changeset has no changes" do
    subject { Pull.new(local: [], server: []) }

    before do
      expect(changeset).to receive(:has_changes?) { false }
    end

    it "has no changes" do
      expect(subject).not_to have_changes
    end
  end

  context "when the changeset has changes" do
    subject { Pull.new(local: [], server: []) }

    before do
      expect(changeset).to receive(:has_changes?) { true }
    end

    it "has changes" do
      expect(subject).to have_changes
    end
  end

  context "when there are no local posts or server posts" do
    subject { Pull.new(local: [], server: []) }
    
    it "doesn't add any posts to the changeset" do
      expect(changeset).not_to receive(:add_local_post)
      expect(changeset).not_to receive(:add_server_post)
      subject.changeset
    end
  end

  context "when there are local posts" do
    let(:local_post) { rendered_post(path: 'standard/foo.md', content: '') }
    let(:parsed_local_post) { make_server_post(id: 1) }

    subject { Pull.new(local: [local_post], server: []) }

    before do
      expect(Pressy::PostParser).to receive(:parse).with(format: 'standard', content: '') { parsed_local_post }
    end

    it "adds the local post to the changeset" do
      expect(changeset).to receive(:add_local_post).with(1, local_post)
      expect(changeset).not_to receive(:add_server_post)
      subject.changeset
    end
  end

  context "when there are server posts" do
    let(:server_post) { make_server_post(id: 2) }
    let(:rendered_server_post) { rendered_post }

    subject { Pull.new(local: [], server: [server_post]) }

    before do
      expect(Pressy::PostRenderer).to receive(:render).with(server_post) { rendered_server_post }
    end

    it "adds the server post to the changeset" do
      expect(changeset).not_to receive(:add_local_post)
      expect(changeset).to receive(:add_server_post).with(2, rendered_server_post)
      subject.changeset
    end
  end
end

def rendered_post(params = {})
  instance_double("Pressy::RenderedPost", params)
end

def make_server_post(params = {})
  instance_double("Wordpress::Post", params)
end
