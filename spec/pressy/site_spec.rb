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
    subject(:push) { site.push }

    context "when the site is empty" do
      it "has no changes" do
        expect_push(
          local: [],
          server: [],
          has_changes?: false,
          changeset: make_changeset
        )

        expect(wordpress).not_to receive(:create_post)
        # expect(wordpress).not_to receive(:edit_post)

        expect(push).not_to have_changes
      end
    end

    context "when the store has a new post" do
      let(:new_post) { double(:new_post) }
      let(:saved_post) { double(:saved_post) }
      let(:rendered_saved_post) { double(:rendered_saved_post) }

      it "creates the post on the server and updates the local copy" do
        expect_push(
          local: [new_post],
          server: [],
          has_changes?: true,
          changeset: make_changeset(added_posts: [new_post])
        )

        expect(wordpress).to receive(:create_post).with(new_post) { saved_post }
        expect(Pressy::PostRenderer).to receive(:render).with(saved_post) { rendered_saved_post }
        expect(store).to receive(:write).with(rendered_saved_post)

        expect(push).to have_changes
      end
    end

    context "when the store has an edited post" do
      let(:edited_post) { double(:edited_post) }
      let(:updated_post) { double(:updated_post) }
      let(:rendered_post) { double(:rendered_post) }
      let(:server_post) { double(:server_post) }

      it "updates the post on the server and updates the local copy" do
        expect_push(
          local: [edited_post],
          server: [server_post],
          has_changes?: true,
          changeset: make_changeset(updated_posts: {1 => edited_post})
        )

        expect(wordpress).to receive(:edit_post).with(edited_post) { updated_post }
        expect(Pressy::PostRenderer).to receive(:render).with(updated_post) { rendered_post }
        expect(store).to receive(:write).with(rendered_post)

        expect(push).to have_changes
      end
    end

    def expect_push(params)
      params = params.dup
      local = params.delete(:local)
      server = params.delete(:server)

      expect(store).to receive(:all_posts) { local }
      expect(wordpress).to receive(:fetch_posts) { server }

      expect(Pressy::Action::Push).to receive(:new).with(local: local, server: server) {
        double(:push, params)
      }
    end

    PUSH_CHANGESET_DEFAULTS = {
      added_posts: [],
      updated_posts: {},
      deleted_posts: {}
    }

    def make_changeset(params = {})
      double(:changeset, PUSH_CHANGESET_DEFAULTS.merge(params))
    end
  end
end
