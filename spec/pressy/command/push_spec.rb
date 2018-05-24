require 'spec_helper'

PushCommand = Pressy::Command::Push

RSpec.describe PushCommand do
  let(:stderr) { StringIO.new }
  let(:changeset) { instance_double("Pressy::RemoteChangeset") }
  let(:push) { double(:push, changeset: changeset) }
  let(:site) { instance_double("Pressy::Site") }

  subject { PushCommand.new(site, stderr) }

  before do
    allow(site).to receive(:push) { push }
  end

  it "has command name 'push'" do
    expect(PushCommand.name).to be :push
  end

  context "when the site has no changes" do
    before do
      allow(changeset).to receive(:has_changes?) { false }
    end

    it "reports that the site is already up-to-date" do
      subject.run
      expect(stderr.string).to eq "Already up-to-date.\n"
    end
  end

  context "when the site has some changes" do
    let(:changeset) {
      instance_double("Pressy::RemoteChangeset", {
        has_changes?: true,
        added_posts: [double, double],
        updated_posts: [double],
        deleted_posts: [double, double, double]
      })
    }

    it "reports the counts of the changes" do
      subject.run
      expect(stderr.string).to eq <<OUTPUT
Added 2 posts.
Updated 1 posts.
Deleted 3 posts.
OUTPUT
    end
  end
end
