require 'spec_helper'

PullCommand = Pressy::Command::Pull

RSpec.describe PullCommand do
  let(:stderr) { StringIO.new }
  let(:changeset) { instance_double("Pressy::LocalChangeset") }
  let(:pull) { double(:pull, changeset: changeset) }
  let(:site) { instance_double("Pressy::Site") }

  subject { PullCommand.new(site, stderr) }

  before do
    allow(site).to receive(:pull) { pull }
  end

  it "has command name 'pull'" do
    expect(PullCommand.name).to be :pull
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
      instance_double("Pressy::LocalChangeset", {
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