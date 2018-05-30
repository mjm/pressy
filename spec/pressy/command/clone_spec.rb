require 'spec_helper'

CloneCommand = Pressy::Command::Clone

RSpec.describe CloneCommand do
  let(:site) { double(:site) }
  let(:console) { double(:console) }
  subject { CloneCommand.new(site, console) }

  it "has command name 'clone'" do
    expect(CloneCommand.name).to be :clone
  end

  context "when no site URL is provided" do
    it "raises an error" do
      expect { subject.run }.to raise_error("no site URL provided")
    end
  end

  let(:clone_url) { "http://example.com" }

  context "when a site URL is provided" do
    it "prompts for authentication details and initializes the site" do
      expect(console).to receive(:prompt).with("Username:") { "john" }
      expect(console).to receive(:prompt).with("Password:", echo: false) { "password" }

      expect(site).to receive(:clone).with(url: clone_url, path: nil, username: "john", password: "password")

      subject.run(clone_url)
    end

    it "supports passing a directory name for the clone" do
      expect(console).to receive(:prompt).with("Username:") { "john" }
      expect(console).to receive(:prompt).with("Password:", echo: false) { "password" }

      expect(site).to receive(:clone).with(url: clone_url, path: "dir", username: "john", password: "password")

      subject.run(clone_url, "dir")
    end
  end
end
