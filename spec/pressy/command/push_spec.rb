require 'spec_helper'

RSpec.describe Pressy::Command::Push do
  include_examples "command", :push

  let(:changeset) { instance_double("Pressy::RemoteChangeset") }
  let(:push) { double(:push, changeset: changeset) }

  before do
    allow(site).to receive(:push) { push }
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
        changes: [
          double(type: :add),
          double(type: :add),
          double(type: :update),
          double(type: :delete),
          double(type: :delete),
          double(type: :delete),
        ]
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
