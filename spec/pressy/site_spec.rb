require 'spec_helper'

RSpec.describe Pressy::Site do
  let(:config) do
      {
        "site" => {
          "host" => "example.com",
          "username" => "alex",
          "password" => "pressy",
        },
      }
  end
  let(:store) { instance_double("Pressy::Store::FileStore") }
  let(:wordpress) { instance_double("Pressy::Client") }
  subject(:site) { Pressy::Site.new(store) }

  before(:each) do
    allow(store).to receive(:configuration) { config }
    allow(Pressy::Client).to receive(:connect) { wordpress }
  end

  it "creates a new site with a configured client" do
    expected_config = { host: "example.com", username: "alex", password: "pressy" }
    expect(Pressy::Client).to receive(:connect).with(expected_config) { wordpress }
    Pressy::Site.new(store)
  end

  describe "pulling changes" do
    let(:local_posts) { [double(:local1), double(:local2)] }
    let(:server_posts) { [double(:server1), double(:server2)] }
    let(:changeset) { double(:changeset, has_changes?: true, changes: [change1, change2]) }
    let(:action) { double(:pull, has_changes?: true, changeset: changeset) }

    let(:change1) { double(:change1) }
    let(:change2) { double(:change2) }

    subject(:pull) { site.pull }

    it "executes all of the changes in the changeset" do
      expect(store).to receive(:all_posts) { local_posts }
      expect(wordpress).to receive(:fetch_posts) { server_posts }
      expect(Pressy::Action::Pull).to receive(:new).with(local: local_posts, server: server_posts) { action }

      expect(change1).to receive(:execute).with(store)
      expect(change2).to receive(:execute).with(store)

      expect(pull).to have_changes
    end
  end

  describe "pushing changes" do
    let(:local_posts) { [double(:local1), double(:local2)] }
    let(:server_posts) { [double(:server1), double(:server2)] }
    let(:changeset) { double(:changeset, has_changes?: true, changes: [change1, change2]) }
    let(:action) { double(:push, has_changes?: true, changeset: changeset) }

    let(:change1) { double(:change1) }
    let(:change2) { double(:change2) }

    subject(:push) { site.push }

    it "executes all of the changes in the changeset" do
      expect(store).to receive(:all_posts) { local_posts }
      expect(wordpress).to receive(:fetch_posts) { server_posts }
      expect(Pressy::Action::Push).to receive(:new).with(local: local_posts, server: server_posts) { action }

      expect(change1).to receive(:execute).with(store, wordpress)
      expect(change2).to receive(:execute).with(store, wordpress)

      expect(push).to have_changes
    end
  end
end
