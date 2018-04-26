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
  let(:wordpress) { instance_double("Wordpress") }
  subject(:site) { Pressy::Site.new(store) }

  before(:each) do
    allow(store).to receive(:configuration) { config }
    allow(Wordpress).to receive(:connect) { wordpress }
  end

  it "creates a new site with a configured Wordpress client" do
    expect(Wordpress).to receive(:connect).with(config) { wordpress }
    Pressy::Site.new(store)
  end

  describe "pulling changes" do
    context "when the site is empty" do
      it "has no changes" do
        expect_pull local: [], server: [], has_changes?: false
        expect(store).not_to receive(:write)
        expect(store).not_to receive(:write_digests)

        expect(site.pull).not_to have_changes
      end
    end

    context "when the site is up-to-date" do
      it "has no changes" do
        expect_pull(
          local: [double(:local_post)],
          server: [double(:server_post)],
          has_changes?: false
        )

        expect(store).not_to receive(:write)
        expect(store).not_to receive(:write_digests)

        expect(site.pull).not_to have_changes
      end
    end

    context "when the site has a new post" do
      it "pulls a site with one new post" do
        expect_pull(
          local: [],
          server: [double(:server_post)],
          has_changes?: true
        )

        # expect(store).to receive(:write).with(rendered_post1)
        # expect(store).to receive(:write_digests).with({ 1 => rendered_post1.digest })

        expect(site.pull).to have_changes
      end
    end

    def expect_pull(params)
      params = params.dup
      local = params.delete(:local)
      server = params.delete(:server)

      expect(store).to receive(:all_posts) { local }
      expect(wordpress).to receive(:fetch_posts) { server }

      expect(Pressy::Action::Pull).to receive(:new).with(local: local, server: server) {
        double(:pull, params)
      }
    end
  end
end
