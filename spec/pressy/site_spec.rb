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
    Pressy::Site.new(store).client
  end

  context "when the store does not have a site configuration" do
    let(:config) { {} }

    it "can be initialized" do
      expect { site }.not_to raise_error
    end

    it "raises an error when trying to use the client" do
      expect { site.client }.to raise_error("no site configuration found in this directory")
    end
  end

  it "has a root directory that delegates to the store" do
    expect(store).to receive(:root) { "/foo/bar" }
    expect(site.root).to eq "/foo/bar"
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

  describe "creating a single post" do
    let(:new_post) { double(:new_post) }
    let(:saved_post) { double(:saved_post, id: 123) }
    let(:rendered_saved_post) { double(:rendered_saved_post, path: "foo/bar.md") }

    it "creates the post and saves it to the store" do
      expect(wordpress).to receive(:create_post).with(new_post) { saved_post }
      expect(Pressy::PostRenderer).to receive(:render).with(saved_post) { rendered_saved_post }
      expect(store).to receive(:write).with(123, rendered_saved_post)

      site.create_post(new_post)
    end
  end

  describe "creating a new site" do
    let(:user) { "john" }
    let(:password) { "password" }
    let(:new_store) { double(:new_store) }

    it "creates in an explicitly specified directory" do
      expect(store).to receive(:create).with("foo", {
        "site" => {
          "host" => "example.com",
          "username" => user,
          "password" => password
        }
      }) { new_store }

      new_site = site.create(
        url: "https://example.com/",
        username: user,
        password: password,
        path: "foo"
      )
      expect(new_site.store).to be new_store
    end

    it "creates in an implicitly named directory based off the hostname" do
      expect(store).to receive(:create).with("example.com", {
        "site" => {
          "host" => "example.com",
          "username" => user,
          "password" => password
        }
      }) { new_store }

      new_site = site.create(
        url: "https://example.com",
        path: nil,
        username: user,
        password: password,
      )
      expect(new_site.store).to be new_store
    end

    it "correctly configures for a site hosted at a subpath" do
      expect(store).to receive(:create).with("example.com", {
        "site" => {
          "host" => "example.com",
          "path" => "/foo/bar/xmlrpc.php",
          "username" => user,
          "password" => password
        }
      }) { new_store }

      new_site = site.create(
        url: "https://example.com/foo/bar",
        username: user,
        password: password,
      )
      expect(new_site.store).to be new_store
    end
  end

  it "has a default site for the current file store" do
    expect(Pressy::Store::FileStore).to receive(:current) { store }
    expect(Pressy::Site.current.store).to be store
  end
end
