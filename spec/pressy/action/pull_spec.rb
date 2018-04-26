require 'spec_helper'

Pull = Pressy::Action::Pull

RSpec.describe Pressy::Action::Pull do
  context "when there are no local posts or server posts" do
    subject { Pull.new(local: [], server: []) }
    
    it "has no changes" do
      expect(subject).not_to have_changes
    end
  end

  context "when the local and server posts are the same" do
    let(:local_posts) {
      [rendered_post(path: 'standard/foo.md', content: '', digest: "abc")]
    }
    let(:parsed_local_post) { server_post(id: 1) }
    let(:server_posts) { [server_post(id: 1)] }
    let(:rendered_server_post) { rendered_post(digest: "abc") }

    subject { Pull.new(local: local_posts, server: server_posts) }

    before(:each) do
      expect(Pressy::PostRenderer).to receive(:render).with(server_posts.first) { rendered_server_post }
      expect(Pressy::PostParser).to receive(:parse).with(format: 'standard', content: '') { parsed_local_post }
    end

    it "has no changes" do
      expect(subject).not_to have_changes
    end
  end

  context "when the server has changed a local post" do
    context "and the local post is not modified" do
      let(:local_posts) {
        [rendered_post(path: 'standard/foo.md', content: '', digest: "abc")]
      }
      let(:parsed_local_post) { server_post(id: 1) }
      let(:server_posts) { [server_post(id: 1)] }
      let(:rendered_server_post) { rendered_post(digest: "def") }

      subject { Pull.new(local: local_posts, server: server_posts) }

      before(:each) do
        expect(Pressy::PostRenderer).to receive(:render).with(server_posts.first) { rendered_server_post }
        expect(Pressy::PostParser).to receive(:parse).with(format: 'standard', content: '') { parsed_local_post }
      end

      it "has changes" do
        expect(subject).to have_changes
      end
    end
  end

  context "when the server has added a new post" do
    let(:local_posts) { [] }
    let(:server_posts) { [server_post(id: 1)] }
    let(:rendered_server_post) { rendered_post(digest: "def") }

    subject { Pull.new(local: local_posts, server: server_posts) }

    before(:each) do
      expect(Pressy::PostRenderer).to receive(:render).with(server_posts.first) { rendered_server_post }
    end

    it "has changes" do
      expect(subject).to have_changes
    end
  end
end

def rendered_post(params = {})
  instance_double("Pressy::RenderedPost", params)
end

def server_post(params = {})
  instance_double("Wordpress::Post", params)
end
