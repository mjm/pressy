require 'spec_helper'

RSpec.describe Pressy::Command::Clone do
  include_examples "command", :clone

  context "when no site URL is provided" do
    it "raises an error" do
      expect { subject.run({}) }.to raise_error("no site URL provided")
    end
  end

  let(:clone_url) { "http://example.com" }
  let(:new_site) { double(:new_site, root: "/foo/bar/dir") }
  let(:pull) {
    double(:pull, changeset: double(:changeset, changes: [
      double(type: :add),
      double(type: :add)
    ], has_changes?: true))
  }

  context "when a site URL is provided" do
    it "prompts for authentication details and initializes the site" do
      expect(console).to receive(:prompt).with("Username:") { "john" }
      expect(console).to receive(:prompt).with("Password:", echo: false) { "password" }

      expect(site).to receive(:create).with(url: clone_url, path: nil, username: "john", password: "password") { new_site }
      expect(new_site).to receive(:pull) { pull }

      subject.run({}, clone_url)

      expect(stderr.string).to eq <<~ERROR

        Created new site in /foo/bar/dir.
        Added 2 posts.
        ERROR
    end

    it "supports passing a directory name for the clone" do
      expect(console).to receive(:prompt).with("Username:") { "john" }
      expect(console).to receive(:prompt).with("Password:", echo: false) { "password" }

      expect(site).to receive(:create).with(url: clone_url, path: "dir", username: "john", password: "password") { new_site }
      expect(new_site).to receive(:pull) { pull }

      subject.run({}, clone_url, "dir")

      expect(stderr.string).to eq <<~ERROR

        Created new site in /foo/bar/dir.
        Added 2 posts.
        ERROR
    end
  end
end
